# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Testing
- Run tests: `bundle exec rspec`
- Test files are located in `spec/`

### Code Quality
- Run linting: `bundle exec rubocop`

### Core Usage
- Create token set: `ruby bin/create_token.rb [image_file]`
- Create dynamic numbered tokens: `ruby bin/create_token.rb [image_file] [count]`
- Interactive mode: `ruby bin/create_token.rb` (no arguments)
- Thor CLI: `thor create_token:create_token_set [image_file]`
- Thor CLI with dynamic numbering: `thor create_token:create_token_set [image_file] --count=[number]`
- Create printable sheet: `thor create_token:create_printable_sheet [input_path] [output_filename]`

### Dependencies
- Install dependencies: `bundle install`

## Architecture

### Core Components
- **TokenMaker** (`lib/token_maker.rb`): Main class that orchestrates token creation workflows
- **token_functions.rb** (`lib/token_functions.rb`): Contains all image processing logic using RMagick, handles compositing, resizing, and file operations

### Token Creation Workflow
1. **Basic Token Creation**: Composites a base image with border assets from `lib/assets/`
2. **Token Set Generation**: 
   - **Traditional**: Creates numbered variants (0-9) using PNG overlays plus special variants (bloodied, offline)
   - **Dynamic**: Creates any number range (0-N) using RMagick text rendering plus optional special variants
3. **Printable Sheet Creation**: Arranges tokens on letter-size sheets (8.5"x11") with proper DPI for physical printing

### Key Constants
- `TOKEN_INCH_PIXELS = 328.8`: Pixels per inch for 1-inch tokens (calibrated for specific hardware)
- `PAGE_WIDTH/HEIGHT`: Letter size dimensions in pixels
- `TOKENS_PER_ROW/COLUMN`: Grid layout for printable sheets

### Directory Structure
- `lib/assets/`: Contains number overlays (0-9.png) and special state overlays (bloodied.png, offline.png)
- `lib/assets/token_borders/`: Border templates for token creation
- `tokens/`: Default output directory for generated tokens
- `printables/`: Default output directory for printable sheets
- `spec/support/test_images/`: Test assets for RSpec

### Image Processing Details
- Uses RMagick for all image operations
- Supports automatic resizing while maintaining aspect ratios
- Memory management includes explicit image destruction and garbage collection for large batch operations
- Default token size: 256x256 pixels, resized to `TOKEN_INCH_PIXELS` for printing

### CLI Interfaces
- **Simple Ruby script** (`bin/create_token.rb`): Basic token set creation with interactive fallback, supports dynamic numbering
- **Thor CLI** (`bin/create_token.thor`): Advanced interface with options for printable sheets, copy counts, special token inclusion/exclusion, and dynamic numbering

### Dynamic Numbering
- Use `--count=N` with Thor CLI or provide count as second argument to Ruby script
- Generates tokens numbered 0 through N-1 (e.g., `--count=21` creates tokens 0-20)
- Numbers are rendered as white text with black stroke in bottom-right corner
- Special tokens (bloodied, offline) are included by default but can be excluded with `--no-include-special`