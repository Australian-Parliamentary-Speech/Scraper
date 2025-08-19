# Nodes

This document describes what each Julia file in `src/nodes` does during XML parsing, including the crucial phase-specific processing that handles different time periods and XML formats in parliamentary data.

## Phase System Overview

The system processes parliamentary transcripts from different time periods with different XML structures:
- **PhaseSGML** (1981-1997): Earlier SGML-based format 
- **Phase2011** (1998-2011): Later XML format with different structure
- **Default Phase**: Modern format (post-2011)

Each phase has different XML tag names, processing rules, and output formats.

## Base Node Processing Workflows

### AnswerNode.jl - Answer Processing
**What it does:**
1. **Base behavior**: Looks for `<answer>` XML tags in parliamentary transcripts
2. **Continuation handling**: When it finds a "continue" element, checks if the parent node is actually an answer node
3. **Validation**: Confirms that the current XML element should be treated as an answer before processing
4. **Phase awareness**: Uses phase-specific XPath patterns and validation rules

### AnswersToQuestionsNode.jl - Answer Collection Processing
**What it does:**
1. **Structure recognition**: Simply identifies `<answers.to.questions>` sections in the XML
2. **Container role**: Acts as a marker for sections that group multiple answers together
3. **Minimal processing**: Just recognizes this structural element across all phases

### BusinessNode.jl - Business Start Processing
**What it does:**
1. **Session marker**: Identifies `<business.start>` tags that mark the beginning of parliamentary business
2. **Structural role**: Acts as a boundary marker in the document hierarchy
3. **Simple recognition**: No content extraction - just recognizes when business proceedings begin

### ChamberNode.jl - Chamber Transcript Processing
**What it does:**
1. **Container identification**: Identifies `<chamber.xscript>` elements that contain chamber-level transcript data
2. **Document structure**: Marks sections that contain chamber proceedings
3. **Phase-neutral**: Simple recognition logic that works across all phases

### DebateNode.jl - Debate Section Processing
**What it does:**
1. **Section recognition**: Identifies `<debate>` sections in parliamentary transcripts
2. **Title extraction**: Extracts debate title information from `/debateinfo/title` path within the debate
3. **Legacy filtering**: Contains commented logic that would filter out debates titled "BILLS" (currently disabled)
4. **Hierarchical organization**: Provides structural organization for debate-level content
5. **Phase-specific overrides**: Different phases may have different debate structures

### DivisionNode.jl - Voting Division Processing
**What it does:**
1. **Voting identification**: Identifies `<division>` tags that represent parliamentary voting sessions
2. **Structural marker**: Simple recognition for voting-related content sections
3. **Minimal processing**: Just marks division sections for downstream processing

### FedChamberNode.jl - Federal Chamber Processing
**What it does:**
1. **Multi-format support**: Identifies both `<fedchamb.xscript>` (federal chamber) and `<maincomm.xscript>` (main committee) transcript sections
2. **Document type handling**: Processes two different types of parliamentary transcript formats
3. **Root-level recognition**: Simple structural recognition for these high-level transcript containers

### InterTalkNode.jl - Inter-Speaker Dialogue Processing
**What it does:**
1. **Content extraction**: Looks for `<talk.start>` elements and extracts text from `//talk.text` paths
2. **Missing content handling**: If no talk text is found, sets content to a space character
3. **Speaker identification**: Gets talker information from the parent node in the node tree
4. **Context validation**: Ensures the talk is happening within an interjection section
5. **Metadata processing**: Defines various flags and metadata for the dialogue
6. **CSV output**: Creates a complete row of data and writes it to the CSV output
7. **Hierarchical awareness**: Works specifically within `InterjectionNode` sections
8. **Phase-specific processing**: May have different talk text extraction rules per phase

### InterjectionNode.jl - Interjection Section Processing
**What it does:**
1. **Section identification**: Identifies `<interjection>` sections in parliamentary transcripts
2. **Context provision**: Acts as a container/context for `InterTalkNode` processing
3. **Structural organization**: Provides the framework where inter-speaker dialogue occurs

### PNode.jl - Paragraph Content Processing (Most Complex, Highly Phase-Specific)

**Base PNode (Default Phase) - uses `<p>` tags:**
1. **Context identification**: Looks for `<p>` tags within speeches, questions, answers, or business sections
2. **First paragraph detection**: Determines if this is the first `<p>` element under its parent node
3. **Speaker extraction**: Gets speaker from parent node or searches within paragraph content
4. **Content processing**: Handles item labels, cleans text, builds complete records

**Phase2011 PNode - uses `<para>` tags:**
1. **Different XML structure**: Processes `<para>` tags instead of `<p>` tags
2. **Expanded section support**: Can appear in more section types including `AdjournmentNode`, `SubdebateNode`
3. **Advanced first-node detection**: 
   - Always treats nodes under `MotionnospeechNode` as first
   - Checks for "talker" elements two nodes back to determine if it's a first paragraph
4. **Quote node handling**: Special logic where quote nodes act like paragraph containers
5. **InterTalk integration**: Special handling when paragraphs appear within InterTalkNode contexts

**PhaseSGML PNode - uses `<para>` tags with SGML-specific features:**
1. **SGML format processing**: Handles older SGML-based XML structure with `<para>` tags
2. **Parent finding logic**: Uses special `find_p_node_parent()` function for complex parent relationships
3. **Font-based quote detection**: Identifies quotes by checking `@font-size="-=2"` attribute
4. **Nonspeech node detection**: Identifies non-speech content in "NOTICES" and "PAPERS" sections
5. **Special flag handling**: Adds `nonspeech` flag for administrative content without speakers

### QuestionNode.jl - Question Processing
**What it does:**
1. **Question identification**: Identifies `<question>` XML elements in Q&A sessions
2. **Continuation support**: Handles "continue" elements by validating parent node context
3. **Validation logic**: Ensures elements should be processed as part of a question
4. **Phase compatibility**: Works across all phases with consistent logic

### SpeechNode.jl - Speech Processing
**What it does:**
1. **Speech recognition**: Identifies `<speech>` XML elements in parliamentary transcripts
2. **Continuation handling**: Processes "continue" elements by checking parent node validity
3. **Context validation**: Ensures elements are part of legitimate speech content
4. **Structural foundation**: Provides framework for speech content processing across phases

### SubdebateNode.jl - Subdebate Processing
**What it does:**
1. **Hierarchical structure**: Identifies `<subdebate.1>` sections within larger debates
2. **Title extraction**: Gets subdebate title information from `/subdebateinfo/title` path
3. **Nested organization**: Creates hierarchical structure within debate frameworks
4. **Multi-level debates**: Enables complex parliamentary discussion organization

## Phase-Specific Node Files

### Phase2011 Specific Nodes (src/nodes/Phases/Phase2011/nodes/)

#### AdjournmentNode.jl - Phase2011 Adjournment Processing
**What it does:**
1. **Adjournment recognition**: Identifies `<adjournment>` tags specific to Phase2011 format
2. **Session boundaries**: Marks adjournment periods in parliamentary sessions
3. **Phase-specific structure**: Only exists in Phase2011, handles 1998-2011 adjournment format

#### InterTalkNode.jl - Phase2011 Inter-Talk Processing (Disabled)
**What it does:**
1. **Recognition only**: Identifies `<talk.start>` elements but doesn't process them
2. **Disabled processing**: `process_node()` and `parse_node()` functions return nothing
3. **Simple validation**: Just checks if node name matches allowed XPath patterns
4. **Phase isolation**: Prevents Phase2011 inter-talk processing, likely due to format differences

#### MotionnospeechNode.jl - Phase2011 Motion Without Speech
**What it does:**
1. **Motion identification**: Recognizes `<motionnospeech>` elements for Phase2011
2. **Non-verbal motions**: Handles parliamentary motions that don't involve speeches
3. **Structural marker**: Provides context for paragraphs that don't have traditional speakers

#### PetitionNode.jl - Phase2011 Petition Processing
**What it does:**
1. **Petition recognition**: Identifies `<petition>` elements in Phase2011 format
2. **Citizen petitions**: Handles public petitions presented to parliament
3. **Context provision**: Provides structural context for petition-related content

#### QuoteNode_.jl - Phase2011 Quote Processing
**What it does:**
1. **Quote identification**: Recognizes `<quote>` elements in Phase2011 documents
2. **Citation handling**: Manages quoted material within parliamentary speeches
3. **Container role**: Acts as a special container that can hold paragraph content

### PhaseSGML Specific Nodes (src/nodes/Phases/PhaseSGML/nodes/)

#### DebateNode.jl - PhaseSGML Debate Processing
**What it does:**
1. **SGML debate formats**: Handles multiple debate types: `<debate>`, `<qwn>`, `<answer.to.qon>`
2. **Question formats**: Processes "questions with notice" (`qwn`) and "answers to questions on notice" (`answer.to.qon`)
3. **Title extraction**: Gets titles from `/title` path instead of `/debateinfo/title`
4. **Expanded recognition**: Recognizes more debate-like structures than the base DebateNode

#### InterTalkNode.jl - PhaseSGML Inter-Talk Processing (Disabled)
**What it does:**
1. **Disabled processing**: Both `process_node()` and `parse_node()` return nothing
2. **Format incompatibility**: Inter-talk processing is turned off for SGML format
3. **Phase isolation**: Prevents SGML inter-talk processing due to structural differences

#### InterjectionNode.jl - PhaseSGML Interjection Processing
**What it does:**
1. **SGML interjection format**: Recognizes `<interject>` tags instead of `<interjection>`
2. **Format adaptation**: Handles the different tag naming convention in SGML format
3. **Context provision**: Provides the same structural role but with SGML-specific tags

#### MotionnospeechNode.jl - PhaseSGML Motion Without Speech
**What it does:**
1. **SGML motion format**: Recognizes `<motionnospeech>` elements in SGML format
2. **Consistent functionality**: Same role as Phase2011 but adapted for SGML structure
3. **Non-speech motions**: Handles motions without associated speeches

#### PetitionNode.jl - PhaseSGML Petition Processing
**What it does:**
1. **Extended petition formats**: Recognizes both `<petition>` and `<petition.grp>` elements
2. **Grouped petitions**: Handles petition groups (`petition.grp`) unique to SGML format
3. **SGML adaptation**: Processes petition content in the older SGML structure

#### QuoteNode_.jl - PhaseSGML Quote Processing
**What it does:**
1. **SGML quote format**: Recognizes `<quote>` elements in SGML documents
2. **Same functionality**: Provides quote recognition consistent with Phase2011
3. **Format adaptation**: Handles quotes within the SGML document structure

#### SubdebateNode.jl - PhaseSGML Subdebate Processing
**What it does:**
1. **Extended subdebate formats**: Recognizes both `<subdebate.1>` and `<question.block>` as subdebates
2. **Question blocks**: Treats question blocks as subdebate-like structures
3. **Title extraction**: Uses `/title` path instead of `/subdebateinfo/title`
4. **SGML hierarchy**: Handles the different hierarchical structure in SGML documents

## Phase Processing Summary

### Phase2011 (1998-2011) Features:
- **Date Range**: 1998-2011 and historical 1901-1980 data
- **New Node Types**: AdjournmentNode for session boundaries
- **Disabled Features**: InterTalkNode processing turned off
- **Enhanced Paragraphs**: More complex parent-child relationships in PNode
- **Additional Content Types**: Petition, quote, motionnospeech support

### PhaseSGML (1981-1997) Features:
- **SGML Format**: Older document structure with different tag names
- **Extended Recognition**: More debate types (qwn, answer.to.qon)
- **Different Tags**: `<interject>` instead of `<interjection>`
- **Grouped Content**: Petition groups (`petition.grp`)
- **Question Blocks**: Question blocks treated as subdebates
- **Disabled Features**: InterTalkNode processing turned off
- **Font Detection**: Uses font attributes for quote detection
- **Nonspeech Detection**: Automatic identification of administrative content

### Processing Differences Across Phases:
1. **Tag Names**: Different XML element names for same concepts
2. **Hierarchical Structure**: Different parent-child relationships
3. **Content Detection**: Different methods for identifying quotes, speakers, etc.
4. **Feature Availability**: Some processing features disabled in certain phases
5. **Output Headers**: Different metadata fields in final CSV output
6. **Validation Rules**: Phase-specific logic for determining node types

The phase system ensures that parliamentary transcripts from different eras are processed consistently while preserving their unique structural characteristics and historical context.
