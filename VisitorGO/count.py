import glob

files = glob.glob("**/*.swift", recursive=True)
print(len(files), files)
count = 0

for file in files:
    with open(file, 'r') as f:
        count += len(f.read().splitlines())

print(count)
