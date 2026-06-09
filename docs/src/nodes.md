# Nodes

This document describes what each Julia file in `src/nodes` does during XML parsing, including the crucial phase-specific processing that handles different time periods and XML formats in parliamentary data.

## Phase System Overview

The system processes parliamentary transcripts from different time periods with different XML structures:
- **PhaseSGML** (1981-1997): Earlier SGML-based format 
- **Phase2011** (1998-2011, plus historical 1901-1980 data): Later XML format with different structure
- **Default Phase**: Modern format (post-2011)

The phase system ensures that parliamentary transcripts from different eras are processed differently according to their unique structural characteristics.

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
4. **Filtering**: Contains commented logic that would filter out debates titled "BILLS" (currently disabled)

### DebateTextNode.jl - Debate Text Container Processing
**What it does:**
1. **Container identification**: Identifies `<debate.text>` and `<subdebate.text>` elements
2. **Simple recognition**: No content extraction - just recognizes the section so PNodes nested within it are picked up

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
1. **Recognition only**: Identifies `<talk.start>` sections via `get_xpaths`, but does not process them
2. **Disabled processing**: `process_node()` and `parse_node()` both `return nothing`, so no row is produced — InterTalk processing is effectively off in *all* phases (the full content-extraction logic is commented out)

### InterjectionNode.jl - Interjection Section Processing
**What it does:**
1. **Session marker**: Identifies `<interjection>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### MotionnospeechNode.jl - Motion Without Speech Processing
**What it does:**
1. **Session marker**: Identifies `<motionnospeech>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### PetitionNode.jl - Petition Processing
**What it does:**
1. **Session marker**: Identifies `<petition>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### PNode.jl - Paragraph Content Processing (Most Complex, Highly Phase-Specific)

**Base PNode (Default Phase) - uses `<p>` tags:**
1. **Context identification**: Looks for `<p>` tags within speech, question, answer, business, debate, subdebate, or debate-text sections
2. **First paragraph detection**: Determines if this is the first `<p>` element under its parent node. This is important for extracting speakers.
3. **Speaker extraction**: Gets speaker from parent node or searches within paragraph content
4. **Content processing**: Handles item flags (speech or answer or question, for example), cleans text

**Phase2011 PNode - uses `<para>` tags:**
1. **Different XML tag**: Processes `<para>` tags instead of `<p>` tags
2. **Expanded section support**: Can appear in more section types including `AdjournmentNode`, `SubdebateNode`
3. **Different first-node detection**: 
   - Always treats nodes under `MotionnospeechNode` as first
   - Checks for "talker" elements two nodes back to determine if it's a first paragraph
4. **Quote node handling**: Special logic where quote nodes act like paragraph containers
5. **InterTalk integration**: Special handling when paragraphs appear within InterTalkNode contexts

**PhaseSGML PNode - uses `<para>` tags with SGML-specific features:**
1. **Different XML tag**: Processes `<para>` tags instead of `<p>` tags
2. **Parent finding logic**: Uses special `find_p_node_parent()` function for complex parent relationships
3. **Font-based quote detection**: Identifies quotes by checking the `@font-size` attribute (in `define_flags`)
4. **Speaker fallback**: When no talker is found on the parent, searches for a `//name` element under the parent path

### QuestionNode.jl - Question Processing
**What it does:**
1. **Question identification**: Identifies `<question>` XML elements in Q&A sessions
2. **Continuation support**: Handles "continue" elements by validating parent node context

### QuoteNode_.jl - Quote Processing
**What it does:**
1. **Session marker**: Identifies `<quote>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins

### SpeechNode.jl - Speech Processing
**What it does:**
1. **Speech recognition**: Identifies `<speech>` XML elements in parliamentary transcripts
2. **Continuation handling**: Processes "continue" elements by checking parent node validity

### SubdebateNode.jl - Subdebate Processing
**What it does:**
1. **Session marker**: Identifies `<subdebate.1>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins
3. **Title extraction**: Gets subdebate title information from `/subdebateinfo/title` path

### TableNode.jl - Table Processing
**What it does:**
1. **Container identification**: Identifies `<table>` elements
2. **Content exclusion**: Recognizes tables specifically so their contents are not captured as speech text

## Phase-Specific Node Files

These files override or extend the base nodes above for a particular phase (e.g. different tag names or section rules). Where a node type also has a base file (such as `MotionnospeechNode`, `PetitionNode`, `QuoteNode_`), the phase-specific file replaces only the differing behavior; everything else is inherited from the base node.

### Phase2011 Specific Nodes (src/nodes/Phases/Phase2011/nodes/)

#### AdjournmentNode.jl - Phase2011 Adjournment Processing
**What it does:**
1. **Session marker**: Identifies `<adjournment>` sections in the XML
2. **Simple recognition**: No content extraction - just recognizes when this section begins
3. **Phase-specific structure**: Only exists in Phase2011, handles 1998-2011 adjournment format

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
- **Enhanced Paragraphs**: More complex parent-child relationships in PNode
- **Additional Content Types**: Petition, quote, motionnospeech support

### PhaseSGML (1981-1997) Features:
- **SGML Format**: Older document structure with different tag names
- **Extended Recognition**: More debate types (qwn, answer.to.qon)
- **Different Tags**: `<interject>` instead of `<interjection>`
- **Grouped Content**: Petition groups (`petition.grp`)

### Processing Differences Across Phases:
1. **Tag Names**: Different XML element names for same concepts
2. **Hierarchical Structure**: Different parent-child relationships
3. **Content Detection**: Different methods for identifying quotes, speakers, etc.
4. **Feature Availability**: Some processing features disabled in certain phases
5. **Output Headers**: Unified across all phases — identical CSV metadata fields (see below)
6. **Validation Rules**: Phase-specific logic for determining node types

## Header Systems Across Phases

All phases share a single, unified header configuration for the final CSV output. The default phase (`NodeModule.jl:488`), Phase2011 (`Phase2011.jl:43`), and PhaseSGML (`PhaseSGML.jl:45`) each define `define_headers` returning the identical set of fields:

- **question_flag**: 1 if within QuestionNode, 0 otherwise
- **answer_flag**: 1 if within AnswerNode, 0 otherwise
- **interjection_flag**: 1 if within InterjectionNode, 0 otherwise
- **speech_flag**: 1 if within SpeechNode, 0 otherwise
- **petition_flag**: 1 if within PetitionNode, 0 otherwise
- **quote_flag**: 1 if within QuoteNode, 0 otherwise
- **motionnospeech_flag**: 1 if within MotionnospeechNode, 0 otherwise
- **chamber_flag**: Chamber type (0=none, 1=chamber, 2=federal, 3=answers)
- **name**: Speaker name
- **name.id**: Speaker ID
- **electorate**: Speaker's electorate
- **party**: Speaker's political party
- **role**: Speaker's parliamentary role
- **page.no**: Page number in original document
- **content**: Text content of the node
- **subdebateinfo**: Title of subdebate section
- **debateinfo**: Title of debate section
- **path**: XML path to the node

Because the header set is unified across phases, every phase produces CSV output with the same columns in the same order, ensuring consistent downstream processing regardless of the source document era. Phases still differ in *how* they populate these fields (tag names, content detection, feature availability), but the output schema is shared.


