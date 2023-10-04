PacletInstall["ChristopherWolfram/OpenAILink"]


BeginPackage["JerryI`WolframJSFrontend`MermaidSupport`", {"ChristopherWolfram`OpenAILink`"}];


Begin["`Private`"];


ChatbookQ[___] := False


ChatbookQ[str_String] := StringMatchQ[str, StartOfString ~~ ".llm" ~~ __]


ChatbookProcessor[expr_String, signature_String, callback_] := 
Module[{str, lines, params}, 
  Print["ChatbookProcessor!"]; 

  lines = StringSplit[expr, EndOfLine]; 
  params = StringSplit[
    StringTrim[lines[[1]], (".llm" ~~ WhitespaceCharacter..) | WhitespaceCharacter..], 
    WhitespaceCharacter..
  ]; 
  str = chatGPT[StringTrim[StringJoin[Rest[lines]]]]; 

  callback[
      str,
      CreateUUID[], 
      "markdown",
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


$chat = {}


chatGPT[query_String] := 
Module[{userMessage, assistMessage}, 
  Check[
    userMessage = OpenAIChatMessageObject["user", query]; 
    AppendTo[$chat, userMessage]; 
    assistMessage = OpenAIChatComplete[$chat]; 
    AppendTo[$chat, assistMessage]; 
    assistMessage["Text"], 

    $chat = {}; 
    "<span style=\"color:red\">**Out of tokens. Chat history cleaned up.**</span>"
  ]
]; 


End[];


EndPackage[];