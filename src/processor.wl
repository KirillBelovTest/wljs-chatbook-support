PacletInstall["ChristopherWolfram/OpenAILink"]


BeginPackage["KirillBelov`WolframJSFrontend`LLMSupport`", {"ChristopherWolfram`OpenAILink`", "JerryI`WSP`", "KirillBelov`WebSocketHandler`"}];


Begin["`Private`"];


ChatbookQ[___] := False


ChatbookQ[str_String] := StringMatchQ[str, StartOfString ~~ ".llm" ~~ __]


ChatbookProcessor[expr_String, signature_String, callback_] := 
Module[{str, lines, params, uuid, uuid1}, 
  Print["ChatbookProcessor!"]; 

  lines = StringSplit[expr, EndOfLine]; 
  params = StringSplit[
    StringTrim[lines[[1]], (".llm" ~~ WhitespaceCharacter..) | WhitespaceCharacter..], 
    WhitespaceCharacter..
  ]; 
  str = chatGPT[StringTrim[StringJoin[Rest[lines]]]]; 

  callback[
    "(*answer[" <> ToString[Length[$chat] / 2] <> "]*)", 
    uuid1 = CreateUUID[], 
    "codemirror", 
    Null, 
    "Type" -> "input"
  ]; 

  Table[
    callback[
      i[["text"]],
      uuid = CreateUUID[], 
      i[["type"]],
      Null, 
      If[i[["type"]] == "codemirror", "Type" -> "input", "Type" -> "output"], 
      "After" -> uuid1
    ]; 
    uuid1 = uuid; 
    
    If[i[["type"]] == "codemirror", 
      callback[
        "(*output*)", 
        uuid = CreateUUID[], 
        "codemirror", 
        Null, 
        "Type" -> "input", 
        "After" -> uuid1
      ]
    ];
    uuid1 = uuid;, 
    
    {i, str}
  ]
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
Module[{result, userMessage, assistMessage, lines}, 
  result = Check[
    userMessage = OpenAIChatMessageObject["user", query]; 
    AppendTo[$chat, userMessage]; 
    assistMessage = OpenAIChatComplete[$chat]; 
    AppendTo[$chat, assistMessage]; 
    assistMessage["Text"], 

    $chat = {}; 
    "<span style=\"color:red\">**Out of tokens. Chat history cleaned up.**</span>"
  ]; 

  lines = StringSplit[result, "```"]; 
  Table[
    <|
      "text" -> If[OddQ[i], StringTrim[lines[[i]]], toCode[lines[[i]]]], 
      "type" -> If[OddQ[i], "markdown", "codemirror"]
    |>, 
    {i, 1, Length[lines]}
  ]
]; 


toCode[code_String] := 
Module[{l = StringSplit[code, "\n"], f, r}, 
  f = l[[1]]; 
  r = StringRiffle[l[[2;;]], "\n"]; 

  Which[
    f === "js", ".js\n" <> r, 
    f === "javascript", ".md\n" <> r, 
    f === "markdown", ".md\n" <> r, 
    f === "html", ".html\n" <> r, 
    f === "wolfram", r,  
    f === "mathematica", r, 
    True, ".md\n```" <> f <> "\n" <> r <> "```"
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