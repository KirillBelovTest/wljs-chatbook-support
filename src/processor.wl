BeginPackage["JerryI`WolframJSFrontend`MermaidSupport`"];


Begin["`Private`"];


ChatbookQ[___] := False


ChatbookQ[str_String] := StringMatchQ[str, StartOfString ~~ ".llm"]


ChatbookProcessor[expr_String, signature_String, callback_] := 
Module[{str, lines, params}, 
  Print["ChatbookProcessor!"]; 

  lines = StringSplit[expr, EndOfLine]; 
  params = StringSplit[
    StringTrim[lines[[1]], (".llm" ~~ WhitespaceCharacter..) | WhitespaceCharacter..], 
    WhitespaceCharacter..
  ]; 
  str = StringTrim[StringJoin[Rest[lines]]]; 

  callback[
      str,
      CreateUUID[], 
      "mermaid",
      Null
  ];
];

JerryI`WolframJSFrontend`Notebook`NotebookAddEvaluator[ChatbookQ -> <|
    "SyntaxChecker"->(True&), 
    "Epilog"->(#&), 
    "Prolog"->(#&), 
    "Evaluator"->ChatbookProcessor
  |>, 
  "HighestPriority"
];


End[];


EndPackage[];