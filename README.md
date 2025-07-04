[![Documentation](https://github.com/Australian-Parliamentary-Speech/Scraper/actions/workflows/documentation.yml/badge.svg)](https://australian-parliamentary-speech.github.io/House_Scraper/)

# To install and run the package
In your preferred directory, clone this repo. In the directory, run:
```
./run Inputs/hansard/hansard.toml
```
The output file will be in Outputs/hansard/{{year}}/

To run different year ranges or a specific year, hansard.toml file needs to be editted.

# To inspect how each node is processed

In the directory src/nodes, all the information regarding how each node is processed is stored in the corresponding file. For example, how nodes with nodename "p" would be stored in PNode.jl. The detailed documentation can be accessed in both docs/build/nodes/index.html or the docstrings in each function.




