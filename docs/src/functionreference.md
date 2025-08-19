# Function references
## ParlinfoSpeechScraper
```@meta
CurrentModule = ParlinfoSpeechScraper
```

```@autodocs
Modules = [ParlinfoSpeechScraper]
```

## RunModule
```@meta
CurrentModule = ParlinfoSpeechScraper.RunModule
```

```@autodocs
Modules = [RunModule]
```

## XMLModule

```@meta
CurrentModule = ParlinfoSpeechScraper.RunModule.EditModule
```

```@autodocs
Modules = [EditModule]
```


## NodeModule
```@meta
CurrentModule = ParlinfoSpeechScraper.RunModule.NodeModule
```

```@docs
detect_phase(date, which_house)
```

```@docs
get_all_subtypes(type,st=())
```

```@docs
reverse_find_first_node_name(node_tree,names)
```

```@docs
reverse_find_first_node_not_name(node_tree,names)
```

```@docs
get_talker_from_parent(node::Node,parent_node::Node)
```

```@docs
detect_node_type(node,node_tree,date,soup,PhaseType)
```

```@docs
parse_node(node::Node,node_tree,io)
```

```@docs
process_node(node::Node,node_tree)
```

```@docs
is_nodetype(node,node_tree, nodetype::Type{<:AbstractNode}, phase::Type{<:AbstractPhase}, soup, args...; kwargs...)
```

```@docs
get_xpaths(::Type{<:N}) where {N <: AbstractNode}
```

```@docs
find_section_title(node_tree,soup,section_type)
```

```@docs
find_chamber(node,node_tree)
```

```@docs
define_flags(node::Node{<:AbstractNode{<:AbstractPhase}},parent_node,node_tree)
```

```@docs
write_test_xml(trigger_node, parent_node, edge_case)
```

## Nodes

```@meta
CurrentModule = ParlinfoSpeechScraper.RunModule.NodeModule
```

## 2012-2024 (default)
Here we show how the nodes are defined for different years.

### PNode
xpaths: "p"
```@docs
get_xpaths(::Type{<:PNode})
```

```@docs
process_node(node::Node{<:PNode},node_tree)
```

```@docs
is_first_node_type(node::Node{<:PNode},parent_node,allowed_names,node_tree)
```

```@docs
find_talker_in_p(p_node::Node{<:PNode})
```

```@docs
p_with_a_as_parent(p_node)
```

```@docs
get_sections(::Type{<:PNode})
```

```@docs
is_nodetype(node, node_tree, nodetype::Type{<:PNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...) 
```

```@docs
parse_node(node::Node{<:PNode},node_tree,io)
```

### InterTalkNode
xpaths: "talk.start"
```@docs
get_xpaths(::Type{<:InterTalkNode})
```

```@docs
process_node(node::Node{<:InterTalkNode},node_tree)
```

```@docs
get_sections(::Type{<:InterTalkNode})
```

```@docs
is_nodetype(node, node_tree, nodetype::Type{<:InterTalkNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...) 
```

### Placeholder nodes
##### AnswerNode
xpaths: "answer"
##### BusinessNode
xpaths: "business.start"
##### ChamberNode
xpaths: "chamber.xscript"
##### FedChamberNode
xpaths: "fedchamb.xscript", "maincomm.xscript"
##### DebateNode
xpaths: "debate"
##### DivisionNode
xpaths: "division"
##### InterjectionNode
xpaths: "interjection", "continue"
##### QuestionNode
xpaths: "question"
##### SpeechNode
xpaths: "speech", "question", "answer"
##### SubdebateNode
xpaths: "subdebate.1"

## before April 2011 (exclude 1981-1997)
Phase information:
### Phase2011
```@docs
define_flags(node::Node{<:AbstractNode{Phase2011}},parent_node,node_tree)
```
### PNode
xpaths: "para"
```@docs
get_xpaths(::Type{PNode{Phase2011}})
```

```@docs
get_sections(::Type{PNode{Phase2011}})
```

```@docs
is_first_node_type(node::Node{PNode{Phase2011}},parent_node,allowed_names,node_tree)
```
### Placeholder nodes
##### MotionnospeechNode
xpaths: "motionnospeech"

##### PetitionNode
xpaths: "petition"

##### QuoteNode_
xpaths: "quote"

## 1981-1997 (SGML)
### PNode
xpaths: "para"
```@docs
get_xpaths(::Type{PNode{PhaseSGML}})
```

```@docs
get_sections(::Type{PNode{PhaseSGML}})
```










