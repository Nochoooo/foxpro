import sys, struct
from pathlib import Path

if len(sys.argv) != 2:
    print('Usage: patch_puti.py C:\\CEX\\PUTI.DBF')
    raise SystemExit(2)

path = Path(sys.argv[1])
data = bytearray(path.read_bytes())
if len(data) < 33:
    raise RuntimeError('Invalid DBF: file too small')

header_len = struct.unpack_from('<H', data, 8)[0]
record_len = struct.unpack_from('<H', data, 10)[0]
num_fields = (header_len - 33) // 32

fields=[]
for i in range(num_fields):
    off=32+i*32
    raw=bytes(data[off:off+11]).split(b'\0',1)[0]
    name=raw.decode('latin1').strip().upper()
    flen=data[off+16]
    fields.append((name, off, flen))

names=[f[0] for f in fields]
try:
    ind_idx=names.index('IND_ARM')
    adr_idx=names.index('IM_ADR')
    val_idx=names.index('ADRES')
except ValueError as e:
    raise RuntimeError(f'Required PUTI field missing: {e}. Fields: {names}')

# Visual FoxPro DBF uses field descriptors followed by records.
# Preserve exact field widths and spacing.
field_offsets=[]
pos=header_len
for name, off, flen in fields:
    field_offsets.append(pos)
    pos += flen

changes={
    'AD_START': r'C:\PDO\CEX\',
    'AD_NORM': r'C:\NORMATIV\',
    'AD_NORMS': r'C:\FOXPRO_CONTROL\NET_MIRROR\',
    'AD_VIG': r'C:\FOXPRO_CONTROL\DAT\',
    'AD_NETR': r'C:\FOXPRO_CONTROL\NET_RESTRICTED\',
}

records=struct.unpack_from('<I', data, 4)[0]
changed=[]
for r in range(records):
    roff=header_len + r*record_len
    ind_raw=bytes(data[roff+field_offsets[ind_idx]-header_len: roff+field_offsets[ind_idx]-header_len+fields[ind_idx][2]])
    try: ind=int(ind_raw.decode('cp1251','ignore').strip() or '0')
    except ValueError: continue
    if ind != 20: continue
    adr_raw=bytes(data[roff+field_offsets[adr_idx]-header_len: roff+field_offsets[adr_idx]-header_len+fields[adr_idx][2]])
    key=adr_raw.decode('cp1251','ignore').strip().upper()
    if key in changes:
        foff=field_offsets[val_idx]
        flen=fields[val_idx][2]
        text=changes[key].encode('cp1251')
        if len(text)>flen: raise RuntimeError(f'Path too long for ADRES field ({flen}): {changes[key]}')
        data[roff+foff:roff+foff+flen] = text + b' '*(flen-len(text))
        changed.append((r+1,key,changes[key]))

path.write_bytes(data)
print(f'Patched {path}; records changed: {len(changed)}')
for item in changed: print(item)
