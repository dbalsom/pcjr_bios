#!/usr/bin/env python3
import struct
import os
import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description="Extract PCjr ROM from DOS MZ executable.")
    parser.add_argument("input", help="Input .exe file")
    parser.add_argument("output", help="Output .bin file")
    parser.add_argument("--split", action="store_true", 
                        help="Split the output sequentially into two 32KB files (_low and _high)")
    parser.add_argument("--checksum", action="store_true", 
                        help="Pad to 64KB and apply IBM 8-bit checksum to the final byte")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        sys.exit(f"Error: File '{args.input}' not found.")

    with open(args.input, 'rb') as f:
        header = f.read(32)
        
        if len(header) < 32 or header[:2] not in (b'MZ', b'ZM'):
            sys.exit("Error: Invalid MZ DOS executable signature.")

        bytes_on_last_page = struct.unpack('<H', header[2:4])[0]
        total_pages        = struct.unpack('<H', header[4:6])[0]
        reloc_items        = struct.unpack('<H', header[6:8])[0]
        header_paragraphs  = struct.unpack('<H', header[8:10])[0]

        header_size_bytes = header_paragraphs * 16
        logical_size = total_pages * 512
        if bytes_on_last_page != 0:
            logical_size -= (512 - bytes_on_last_page)

        payload_size = logical_size - header_size_bytes

        if reloc_items > 0:
            print(f"Warning:     {reloc_items} relocation items present.")

        f.seek(header_size_bytes)
        # Read as bytearray so we can modify it
        payload = bytearray(f.read(payload_size))

    # Normalize to exactly 64KB if splitting or checksumming
    if args.split or args.checksum:
        original_len = len(payload)
        if original_len < 65536:
            payload.extend(b'\xFF' * (65536 - original_len))
            print(f"Padding:     {65536 - original_len} bytes added (0xFF).")
        elif original_len > 65536:
            payload = payload[:65536]
            print(f"Truncating:  {original_len - 65536} bytes removed.")

    if args.checksum:
        payload_sum = sum(payload[:-1])
        chk_byte = (256 - (payload_sum % 256)) % 256
        payload[-1] = chk_byte
        print(f"Checksum:    0x{chk_byte:02X} written to final byte.")

    if args.split:
        low_rom = payload[:32768]
        high_rom = payload[32768:]

        base, ext = os.path.splitext(args.output)
        out_low = f"{base}_low{ext}"
        out_high = f"{base}_high{ext}"

        with open(out_low, 'wb') as f: 
            f.write(low_rom)
        with open(out_high, 'wb') as f: 
            f.write(high_rom)

        print(f"Input file:  {args.input}")
        print(f"Output 1:    {out_low} ({len(low_rom)} bytes) [F0000-F7FFF]")
        print(f"Output 2:    {out_high} ({len(high_rom)} bytes) [F8000-FFFFF]")

    else:
        with open(args.output, 'wb') as f:
            f.write(payload)
            
        print(f"Input file:  {args.input}")
        print(f"Output file: {args.output} ({len(payload)} bytes)")

if __name__ == "__main__":
    main()