import subprocess

names = {
	'a': 'Bottoms up',
	'b': 'Masterdrink',
	'c': 'Never have I ever',
	'd': 'Kategorien',
	'e': 'Abstimmungen',
	'f': 'Fragedame'
}

files = []

print('cp ~/Downloads/Cards\\ -\\ authors.csv authors.csv')
#subprocess.run([ 'mv', '~/Downloads/Cards\\ -\\ authors.csv', 'authors.csv' ])
for id in names:
	name = '\\ '.join(names[id].split(' '))
	print('cp ~/Downloads/Cards\\ -\\ %s_\\ %s.csv deck_%s.csv' % (id, name, id))
	#subprocess.run([ 'mv', '\'~/Downloads/Cards - %s_ %s.csv\'' % (id, names[id]), 'deck_%s.csv' % (id) ])
	files.append('deck_%s.csv' % (id))

convert_command = [ 'python', 'converter.py', 'authors.csv' ]
convert_command += files
print(' '.join(convert_command))
#subprocess.run(convert_command)

for id in names:
	print('mv deck_de_%s.txt ../assets/deck_de_%s.txt' % (id, id))
	#subprocess.run([ 'mv', 'deck_de_%s.txt' % (id), '../assets/deck_de_%s.txt' % (id) ])
