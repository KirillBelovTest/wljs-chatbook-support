PacletInstall["ChristopherWolfram/OpenAILink"]


BeginPackage["KirillBelov`WolframJSFrontend`LLMSupport`", {"ChristopherWolfram`OpenAILink`", "JerryI`WSP`", "KirillBelov`WebSocketHandler`"}];


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

DefaultSerializer = ExportByteArray[#, "ExpressionJSON"]&

(* will be called directly via websocket by JS on apikey.wsp component*)
installAPIKey[key_String] := (
  SystemCredential["OPENAI_API_KEY"] = StringTrim[key];
  WebSocketSend[Global`client, Global`Alert["API Key installed! Probably you need to restart the system."] // DefaultSerializer];
);

root = $InputFileName // DirectoryName // ParentDirectory;

(* extend the settings menu *)
JerryI`WolframJSFrontend`Extensions`ExtendSettings[Function[Null,
  LoadPage["settings/apikey.wsp", {}, "Base"->root]
], "LLM OpenAI"];


End[];


EndPackage[];