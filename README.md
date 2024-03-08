# Token Machine
A personal project designed to take character tokens designed for Tabletop Roleplaying Games (TTRPG) and add identifiers or effects to them.

Planned features:
* Ability to create your own tokens (Will either be an included feature with a GUI or will be exported to its own project)
* Customize how many and/or what tokens are generated

## Usage
Open a command line and cd into the project folder. Call the file and use the path to your token file as a parameter. Afterwards a token folder will be generated which contains all of the token variations.

`ruby bin/create_token.rb testtoken.png`

## Tests
Run the tests by executing:
`bundle exec rspec`