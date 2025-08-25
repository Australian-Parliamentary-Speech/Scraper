# Common Errors

The codebase includes several error messages for debugging and validation purposes:

* **NodeModule.jl:81**: `@error "which_house is not correctly given"`
    - if which\_house is not senate or house
* **QuestionNode.jl:23**: `@error "No phase was produced in questionnode"` 
    - indicates missing phase data in question processing
* **SpeechNode.jl:22**: `@error "No phase was produced in speechnode"`
    - indicates missing phase data in speech processing
