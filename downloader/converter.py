from sys import argv, exit

count = 0

def split_line(line):
	in_quote = False
	res = [ '' ]
	for c in line:
		if c is ',' and not in_quote:
			res.append('')
		else:
			res[-1] += c
			if c is '"':
				in_quote = not in_quote
	return res

def strip_quotes(line):
	is_quoted = len(line) > 2 and line[0] == line[-1] == '"'
	return line[1:-1] if is_quoted else line

def create_authors_set(authors_content):
	authors_content = [line.strip() for line in authors_content][1:]
	authors = {}
	for line in authors_content:
		id, author, mail, cards = split_line(line)
		authors[id] = author
	return authors

def convert_deck(authors, deck_content):
	global count
	deck_content = [line.strip() for line in deck_content]
	name, _, _, id = split_line(deck_content[0])

	with open('deck_de_%s.txt' % (id), 'w+') as output:
		output.write('# Deck %s: %s' % (id, name) + '\n')
		print('# Deck %s: %s' % (id, name))
		deck_content = deck_content[2:]
		output.write('/%d' % (len(deck_content)) + '\n')

		for line in deck_content:
			id, author, content, followup = split_line(line)
			author = authors[author] if len(author) > 0 else author
			content = strip_quotes(content)
			followup = strip_quotes(followup)
			out_line = '%s|%s|%s|%s' % (id, author, content, followup)

			output.write(out_line + '\n')
			print(out_line)
			count += 1

def main():
	global count
	if len(argv) < 3:
		print('Usage: converter.py <authors> <input files>')
		print(argv)
		exit(0)

	authors_filename = argv[1]
	deck_filenames = argv[2:]

	with open(authors_filename) as authors_file:
		authors = create_authors_set(authors_file.readlines())

	for deck_filename in deck_filenames:
		with open(deck_filename) as deck_file:
			convert_deck(authors, deck_file.readlines())

	print('%d cards converted' % (count))

main()
