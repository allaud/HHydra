HHydra
======

Haskell based redirector server for A/B testing (built on Parsec monadic parser combinator)

Intro
======
HHydra is a standalone redirector server primary for complicated A/B testing. It uses special DSL to configure its redirections.

How to run HHydra
======
1. Compile it:
    
    cabal install
  
2. Run it: 
    
    HHydra
    
HHydra listens to port 9000 by default and uses ./config file for configuration.

Configuration
======
Each line of ./config file follows this rule:

`NAME <EXPRESSION[,EXPRESSION...]> [ADDRESS[,ADDRESS...]]` 

Where:

_NAME_ is a rule name. It should not contain spaces.

_EXPRESSION_ is a rule in reverse Polish notation. It can be templated using the following syntax: `#{Header-name}` . Supported operations are `=~` (match by regexp) and `==` (strict match).

_ADDRESS_ is http address to redirect

Config example
======
    chr     <#{User-Agent} Chrome =~>                [http://chrome.ru]
    jr      <#{Path} locale=en =~>                   [http://jetradar.com]
    ab      <#{Path} /new/ab =~, #{Path} /new =~>    [http://a.search.aviasales.ru, http://b.search.aviasales.ru]
    zx      <#{Path} / =~>                           [http://ya.ru]

For Develoment
======
How to make a sandbox:

    cabal sandbox init
    cabal install --only-dependencies
    cabal install

    HHydra
    
(add ~/.cabal/bin to your $PATH to run it w/o prefix)

Look http://www.haskell.org/cabal/users-guide/ for more info.
