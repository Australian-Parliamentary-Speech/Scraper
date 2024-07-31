# ParlinfoSpeechScraper

The ParlinfoSpeechScraper processes the xml files iteratively down the node tree. It reads the xml file from top down and processes one node at a time until it exhausts all content in the xml file.

For a quick run of the program:

```
./run Inputs/hansard/hansard.toml
```


The documentation page is arranged as follows:
Normal usage in terms of inputs and outputs is explained in [Usage](usage.md#section-heading), and more advanced interaction that includes adding a node or phase type is explained in [Advanced usage](advusage.md#section-heading). The current implementation of different nodes in all phases is shown in [Nodes](nodes.md#section-heading). [Function references](functionreference.md#section-heading) shows all the docstrings in the program.

