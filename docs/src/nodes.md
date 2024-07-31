# Nodes

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
find_talker_in_p(p_node)
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

```@docs
get_talker_from_parent(::Type{<:PNode},parent_node)
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

```@docs
get_talker_from_parent(::Type{InterTalkNode},parent_node)
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

## before April 2011
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






