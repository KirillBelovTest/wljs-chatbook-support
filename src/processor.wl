PacletInstall["ChristopherWolfram/OpenAILink"]


BeginPackage["KirillBelov`WolframJSFrontend`LLMSupport`", {"ChristopherWolfram`OpenAILink`", "JerryI`WSP`", "KirillBelov`WebSocketHandler`"}];


Begin["`Private`"];


ChatbookQ[___] := False


ChatbookQ[str_String] := StringMatchQ[str, StartOfString ~~ ".llm" ~~ __]


ChatbookProcessor[expr_String, signature_String, callback_] := 
Module[{str, lines, params, uuid, uuid1}, 
  Print["ChatbookProcessor!"]; 

  str = StringJoin[Rest[StringSplit[expr, EndOfLine]]];

  Map[callback[
    #Text, 
    #UUID, 
    #Format, 
    Null, 
    "Type" -> #Type, 
    "After" -> #After, 
    "Props" -> <|"hidden" -> #Hidden|>
  ]&] @ chatGPT[str]
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
Module[{answer, userMessage, assistMessage, lines}, 
  answer = Check[
    userMessage = OpenAIChatMessageObject["user", query]; 
    AppendTo[$chat, userMessage]; 
    assistMessage = OpenAIChatComplete[$chat]; 
    AppendTo[$chat, assistMessage]; 
    assistMessage["Text"], 

    $chat = {}; 
    "<span style=\"color:red\">**Out of tokens. Chat history cleaned up.**</span>"
  ]; 

  toDialogData[query, answer]
]; 


toDialogData[query_String, answer_String] := 
Module[{queryText, queryPair, uuid, answePair, blocks, answers, format}, 
	queryText = StringTrim[StringJoin[Rest[StringSplit[query, EndOfLine]]]]; 	
	
	queryPair = dialogPair[
		"#### Query[" <> ToString[Length[$chat]/2] <> "]:  \n" <> query, 
		"markdown"
	]; 
	
	blocks = StringSplit["#### Answer[" <> ToString[Length[$chat]/2] <> "]:  \n" <> answer, StartOfLine ~~ "```"]; 
	uuid = queryPair[[-1, "UUID"]];
	
	answers = Table[
		format = If[OddQ[i], "markdown", "codemirror"]; 
		answePair = dialogPair[blocks[[i]], format, uuid]; 
		uuid = answePair[[-1, "UUID"]]; 
		answePair, 
		{i, 1, Length[blocks]}
	];
	
	Flatten[{
		queryPair, 
		answers
	}]
]

toCode[text_String] := 
Module[{rest = StringTrim[StringJoin[Rest[StringSplit[text, "\n"]]]]}, 
	Which[
		StringMatchQ[text, {"md", "markdown"} ~~ __, IgnoreCase -> True], 
			".md\n" <> rest, 
			
		StringMatchQ[text, {"js", "javascript"} ~~ __, IgnoreCase -> True], 
			".js\n" <> rest, 
   
  		StringMatchQ[text, {"mermaid"} ~~ __, IgnoreCase -> True], 
			".mermaid\n" <> rest, 
			
		StringMatchQ[text, {"html"} ~~ __, IgnoreCase -> True], 
			".html\n" <> rest, 
			
		StringMatchQ[text, {"wolfram", "mathematica"} ~~ __, IgnoreCase -> True], 
			rest, 
			
		True, 
			".md\n```" <> text <> "\n```"
	]
]

dialogPair[text_String, format_String, after_String: "Before"] := 
Module[{uuid}, {
	<|
		"Text" -> If[format != "codemirror", ".md\n" <> text, toCode[text]], 
		"Format" -> "codemirror", 
		"Hidden" -> format != "codemirror", 
		"Type" -> "input", 
		"UUID" -> (uuid = CreateUUID[]), 
		"After" -> after
	|>, 
	
	If[format != "codemirror", <|
		"Text" -> text, 
		"Format" -> format, 
		"Hidden" -> False, 
		"Type" -> "output", 
		"UUID" -> CreateUUID[], 
		"After" -> uuid
	|>, Nothing]
}]; 


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
