(*

BuckyGen package

This package provides a function calling the buckygen program from Mathematica.
It supports many but not all of the options of buckygen.  In particular, it uses 
the sparse6 format, which doesn't contain the imbedding information, reducing the
utility of the -o buckygen option (invoked with "PreserveOrientation" -> True).
Additionally, because of how the output of the -r spiral test is structured, it is
not supported either.


  
---------

  Copyright (c) 2017, 2018 Henrik Schumacher, Evan Berkowitz

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
 
 ---------
 
 This package grew out of an answer on the Mathematica StackExchange,
     https://mathematica.stackexchange.com/a/159328/7936
 and its author, Henrik Schumacher, has extended not only the usual StackExchange 
 CC-BY-SA 3.0 license, but also provided his code under GPL 3 for compatibility 
 with the buckygen repository.  Evan Berkowitz used Schumacher's code as a starting
 point for the package as written below.
 
 ---------
 
 History:
 
     06-November-2017   First answer and edits.
     31-August-2018     First put in package form, from an interactive notebook.
*)

BeginPackage["BuckyGen`"]

buckygen::usage = "buckygen[n_Integer, options]
    n is the degree of the fullerenes you wish to generate.
    
    Options largely correspond to the command-line options available for the buckygen executable.
    They correspond as follows:
    
    Flag Option       ->   Default|Otherwise
         \"Verbose\"    ->   False|True                 if False, simply return the list; if True print the stdout of running the buckygen executable.
         
    -S   \"Start\"      ->   False|s_Integer            if not False, produce fullerenes of degree s through n inclusive.
    -d   \"Dual\"       ->   False|True                 if False, faces are triangles; if True vertices are degree 3.
    -I   \"IPR\"        ->   False|True                 if False, ignore the isolated pentagon rule; if True, follow it.
    -r   \"SpiralTest\" ->   False|True                 Completely ignored, totally unsupported.
    -o   \"PreserveOrientation\" -> False|True          if False, ignore orientation information; otherwise consider it.
                                                          As imbeddings are ignored, only affects results if \"RequireNonTrivialGroup\" -> True.
    -V   \"RequireNontrivialGroup\" -> False|Trure,     if False, generate all fullerenes; if True only generate those with a nontrivial group.

"

buckygen::tooSmall =  "The smallest fullerene has 12 vertices, while you asked for fullerenes with `` vertices.";

(* "  -S#  Output all fullerenes with 'i' vertices (# <= i <= n) instead of
       only the fullerenes with 'n' vertices.  Since buckygen recursively
       constructs all fullerenes from smaller fullerenes, using switch -S
       only gives a minor overhead. " *)

buckygen::smallest = "The smallest fullerene has 12 vertices, while you asked to enumerate fullerenes starting at `` vertices.";
buckygen::inconsistent = "You asked to enumerate fullerenes with smallest size `` and largest size ``, which is inconsistent.";

(* "
  -o   Normally, one member of each isomorphism class is written.  If this
       switch is given, one member of each orientation preserving (O-P) 
       isomorphism class is written.
       Since graph6 and sparse6 formats don't encode the imbedding anyway,
       this switch is ignored for output purposes if you use -g or -s." *)

(* "   We use sparse6 to communicate between Mathematica and buckygen, 
       so this information is lost, but still can influence the output 
       if the user specifies \"RequireNontrivialGroup\"\[Rule]True (the -V option)" *)

buckygen::orientation = "Orientation information is not used, except for \"RequireNontrivialGroup\" purposes";

(* "
  -r   Tests if the generated fullerenes have spirals starting at a 
       degree 5 or a degree 6 vertex. Fullerenes which do not have a
       spiral starting at a degree 5 vertex are written to a file named
       \"No_pentagon_spiral_x\". And fullerenes which do not have a spiral
       starting at any vertex of the fullerene are written to a file named
       \"No_spiral_x\"." *)

buckygen::dashr = "buckygen option -r is not supported.";

(* "
  -v   Buckygen will always tell you (by a message to standard error) the
       number of graphs that were produced.  If you specify -v, it might
       tell you some additional statistical information.  For example, if
       you use -o, -v will cause it to also inform you of the number of
       isomorphism classes as well as the number of isomorphism classes
       which are O-P isomorphic to their mirror images." *)

buckygen::verbose = "Verbose output:  ``";

Begin["`Private`"]

(* And finally, the function itself: *)

buckygen[n_Integer, OptionsPattern[{
    "Start" -> False,
    "Dual" -> False,
    "IPR" -> False,
    "SpiralTest" -> False,
    "PreserveOrientation" -> False,
    "RequireNontrivialGroup" -> False,
    "Verbose" -> False
    }]] := Module[{programOutput},
  
  (* Check user input: *)
  
  If[n < 12, Message[buckygen::tooSmall, n]; Return[{}]];
  If[Not[False === OptionValue["Start"]] && OptionValue["Start"] > n, 
   Message[buckygen::inconsistent, OptionValue["Start"], n]; 
   Return[{}]];
  (* Attempt the external call: *)
  programOutput = RunProcess[{
     "buckygen", 
     (* Sparse6 is mandatory *) "-s",
     If[Not[False === OptionValue["Start"]] && 
       OptionValue["Start"] >= 12, 
      "-S" <> ToString[OptionValue["Start"]], Nothing],
     If[Not[False === OptionValue["Start"]] && 
       OptionValue["Start"] < 12, 
      Message[buckygen::smallest, OptionValue["Start"]]; "-S12", 
      Nothing],
     If[OptionValue["IPR"], "-I", Nothing],
     If[OptionValue["Dual"], "-d", Nothing],
     If[OptionValue["SpiralTest"], (Message[buckygen::dashr]; Nothing), 
      Nothing],
     If[OptionValue["PreserveOrientation"],
      If[OptionValue["RequireNontrivialGroup"],
       "-o",
       (Message[buckygen::orientation]; Nothing)],
      Nothing],
     If[OptionValue["RequireNontrivialGroup"], "-V", Nothing],
     ToString[n]
     }];
  If[OptionValue["Verbose"], 
   Message[buckygen::verbose, "StandardError" /. programOutput]];
  If["" == ("StandardOutput" /. programOutput), Return[{}]];
  Flatten@List@ImportString[
     "StandardOutput" /. programOutput,
     "Sparse6"]
  ]

End[]
EndPackage[]