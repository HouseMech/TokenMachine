# Token Machine

A Ruby application for creating game tokens for Tabletop Roleplaying Games (TTRPGs). Takes character images and adds identifiers, effects, and creates printable sheets for physical gaming.

## Features

- **Token Creation**: Composite base images with border assets
- **Dynamic Numbering**: Generate numbered tokens (0-N) with customizable counts
- **Special Variants**: Add bloodied and offline state tokens
- **Printable Sheets**: Arrange tokens on letter-size sheets for printing
- **Batch Processing**: Process entire directories of images

## Installation

```bash
bundle install
```

## Usage

### Basic Ruby Scripts

#### Create Token Set (Traditional)
Creates numbered tokens using PNG overlays (0-9) plus special variants:
```bash
ruby bin/create_token.rb [image_file]

# Working example:
ruby bin/create_token.rb testtoken.png
```

#### Create Token Set (Dynamic Numbering)
Creates any number range (0-N) using dynamically rendered numbers:
```bash
ruby bin/create_token.rb [image_file] [count]

# Working example:
ruby bin/create_token.rb testtoken.png 25
```

#### Interactive Mode
Run without arguments for interactive prompts:
```bash
ruby bin/create_token.rb
```

### Thor CLI Commands

The Thor CLI provides advanced options for token creation and sheet generation. To use these commands, ensure you are in the `/bin` directory.

#### Create Token Set
```bash
thor create_token:create_token_set [image_file]
```

**Options:**
- `--count=N`: Enable dynamic numbering, creates tokens 0 through N-1
- `--include-special`: Include special tokens (bloodied, offline) - default: true

**Examples:**
```bash
# Traditional numbered tokens (0-9) + special variants
thor create_token:create_token_set [image_file]
thor create_token:create_token_set testtoken.png

# Dynamic numbering - creates tokens 0-20
thor create_token:create_token_set [image_file] --count=21
thor create_token:create_token_set testtoken.png --count=21

# Dynamic numbering without special tokens
thor create_token:create_token_set [image_file] --count=15 --no-include-special
thor create_token:create_token_set testtoken.png --count=15 --no-include-special
```

#### Create Single Token
```bash
thor create_token:create_token [image_file] [border_file]
```

**Example:**
```bash
thor create_token:create_token testtoken.png ../lib/assets/token_borders/silver.png
```

#### Create Printable Sheet
```bash
thor create_token:create_printable_sheet [input_path] [output_filename]
```

**Options:**
- `--save-to-directory`: Output directory - default: `/printables`
- `--include-bloodied`: Include bloodied variants - default: true
- `--include-offline`: Include offline variants - default: true
- `--copies`: Number of copies of each token - default: 1

**Examples:**
```bash
# Create printable sheet from tokens directory
thor create_token:create_printable_sheet [input_path] [output_filename]
thor create_token:create_printable_sheet ../tokens character_sheet

# Multiple copies with custom directory
thor create_token:create_printable_sheet [input_path] [output_filename] --copies=3 --save-to-directory=/custom/path
thor create_token:create_printable_sheet ../tokens sheet --copies=3 --save-to-directory=/printables

# Exclude special variants
thor create_token:create_printable_sheet [input_path] [output_filename] --no-include-bloodied --no-include-offline
thor create_token:create_printable_sheet ../tokens clean_sheet --no-include-bloodied --no-include-offline
```

## Directory Structure

```
lib/assets/
├── token_borders/          # Border templates for token creation
├── 0-9.png                # Number overlays for traditional numbering
├── bloodied.png           # Bloodied state overlay
└── offline.png            # Offline state overlay

tokens/                    # Default output directory for generated tokens
printables/               # Default output directory for printable sheets
```

## Image Processing Details

- **Token Size**: 256x256 pixels, resized to 328.8 pixels for 1-inch physical tokens
- **Sheet Size**: Letter size (8.5"x11") at 300 DPI
- **Grid Layout**: Automatic arrangement with cutting margins
- **Memory Management**: Automatic cleanup for large batch operations

## Testing

Run the test suite:
```bash
bundle exec rspec
```

## Code Quality

Run linting:
```bash
bundle exec rubocop
```