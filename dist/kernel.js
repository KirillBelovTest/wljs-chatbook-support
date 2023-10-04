class ChatbookOutputCell {
  dispose() {
    
  }
  
  constructor(parent, data) {
    let elt = document.createElement("div");
    const uid = parent.uid;
    
    elt.classList.add("frontend-object");
    elt.style.display = "block";
    
    parent.element.appendChild(elt);
    parent.element.classList.add('padding-fix');
  
    let container = document.createElement("div");
    container.innerText = data;
  
    elt.appendChild(container);
    
    return this;
  }
}

window.SupportedCells['chatbook'] = {
  view: ChatbookOutputCell
};