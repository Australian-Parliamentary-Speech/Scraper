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

### AnswersToQuestionsNode.jl - Answer Collection Processing
**What it does:**
1. **Session marker**: Identifies `<answers.to.questions>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### BusinessNode.jl - Business Start Processing
**What it does:**
1. **Session marker**: Identifies `<business.start>` tags 
2. **Simple recognition**: No content extraction - just recognizes when business proceedings begin

### ChamberNode.jl - Chamber Transcript Processing
**What it does:**
1. **Container identification**: Identifies `<chamber.xscript>` elements
2. **Simple recognition**: No content extraction - just recognizes when this section begins


### DebateNode.jl - Debate Section Processing
**What it does:**
1. **Session marker**: Identifies `<debate>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins
3. **Title extraction**: Extracts debate title information from `/debateinfo/title` path within the debate
4. **Legacy filtering**: Contains commented logic that would filter out debates titled "BILLS" (currently disabled)

### DivisionNode.jl - Voting Division Processing
**What it does:**
1. **Session marker**: Identifies `<division>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### FedChamberNode.jl - Federal Chamber Processing
**What it does:**
1. **Multi-name support**: Identifies both `<fedchamb.xscript>` (federal chamber) and `<maincomm.xscript>` (main committee) transcript sections
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### InterTalkNode.jl - Inter-Speaker Dialogue Processing
**What it does:**
1. **Content extraction**: Looks for `<talk.start>` elements and extracts text from `//talk.text` paths
2. **Missing content handling**: If no talk text is found, sets content to a space character
3. **Speaker identification**: Gets talker information from the parent node in the node tree
4. **Context validation**: Ensures the talk is happening within an interjection section

### InterjectionNode.jl - Interjection Section Processing
**What it does:**
1. **Session marker**: Identifies `<interjection>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

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

### SpeechNode.jl - Speech Processing
**What it does:**
1. **Speech recognition**: Identifies `<speech>` XML elements in parliamentary transcripts
2. **Continuation handling**: Processes "continue" elements by checking parent node validity

### SubdebateNode.jl - Subdebate Processing
**What it does:**
1. **Session marker**: Identifies `<subdebate.1>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins
3. **Title extraction**: Gets subdebate title information from `/subdebateinfo/title` path

## Phase-Specific Node Files

### Phase2011 Specific Nodes (src/nodes/Phases/Phase2011/nodes/)

#### AdjournmentNode.jl - Phase2011 Adjournment Processing
**What it does:**
1. **Session marker**: Identifies `<adjournment>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins
3. **Phase-specific structure**: Only exists in Phase2011, handles 1998-2011 adjournment format

#### InterTalkNode.jl - Phase2011 Inter-Talk Processing (Disabled)
**What it does:**
1. **Recognition only**: Identifies `<talk.start>` elements but doesn't process them
2. **Disabled processing**: `process_node()` and `parse_node()` functions return nothing
3. **Simple validation**: Just checks if node name matches allowed XPath patterns

#### MotionnospeechNode.jl - Phase2011 Motion Without Speech
**What it does:**
1. **Session marker**: Identifies `<motionnospeech>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

#### PetitionNode.jl - Phase2011 Petition Processing
**What it does:**
1. **Session marker**: Identifies `<petition>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

#### QuoteNode_.jl - Phase2011 Quote Processing
**What it does:**
1. **Session marker**: Identifies `<quote>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### PhaseSGML Specific Nodes (src/nodes/Phases/PhaseSGML/nodes/)

#### DebateNode.jl - PhaseSGML Debate Processing
**What it does:**
1. **SGML debate formats**: Handles multiple debate names: `<debate>`, `<qwn>`, `<answer.to.qon>`
2. **Title extraction**: Gets titles from `/title` path instead of `/debateinfo/title`

#### InterTalkNode.jl - PhaseSGML Inter-Talk Processing (Disabled)
**What it does:**
1. **Disabled processing**: Both `process_node()` and `parse_node()` return nothing
2. **Format incompatibility**: Inter-talk processing is turned off for SGML format

#### InterjectionNode.jl - PhaseSGML Interjection Processing
**What it does:**
1. **Session marker**: Identifies `<interject>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

#### MotionnospeechNode.jl - PhaseSGML Motion Without Speech
**What it does:**
1. **Session marker**: Identifies `<motionnospeech>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

#### PetitionNode.jl - PhaseSGML Petition Processing
**What it does:**
1. **Extended petition names**: Recognizes both `<petition>` and `<petition.grp>` elements
2. **Simple recognition**: No content extraction - just recognizes when this section begins

#### QuoteNode_.jl - PhaseSGML Quote Processing
**What it does:**
1. **Session marker**: Identifies `<quote>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

#### SubdebateNode.jl - PhaseSGML Subdebate Processing
**What it does:**
1. **Extended subdebate names**: Recognizes both `<subdebate.1>` and `<question.block>` as subdebates
2. **Simple recognition**: No content extraction - just recognizes when this section begins
3. **Title extraction**: Uses `/title` path instead of `/subdebateinfo/title`

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
- **Disabled Features**: InterTalkNode processing turned off

### Processing Differences Across Phases:
1. **Tag Names**: Different XML element names for same concepts
2. **Hierarchical Structure**: Different parent-child relationships
3. **Content Detection**: Different methods for identifying quotes, speakers, etc.
4. **Feature Availability**: Some processing features disabled in certain phases
5. **Output Headers**: Different metadata fields in final CSV output
6. **Validation Rules**: Phase-specific logic for determining node types

The phase system ensures that parliamentary transcripts from different eras are processed consistently while preserving their unique structural characteristics and historical context.
