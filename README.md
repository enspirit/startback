# Gyrb - Got Your Ruby Back

Yet another ruby framework, I'm afraid. Here, we srongly seperate between:

1. the web layer, in charge of a quality HTTP handling
2. the operations layer, in charge of the high-level software operations
3. the database layer, abstracted using the Relations As First Class Citizen pattern

Currently,

1. is handled using extra support on top of Sinatra
2. is handled using Gyrb specific classes
3. is handled using Bmg
