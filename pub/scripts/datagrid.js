// We should only invoke datagrid actions when selection is empty
function initiateActionOnEmptySelection(actionCode, sessionString) {
    if(selectionEmpty()) {
	initiateAction(actionCode, sessionString);
	return false;
    }
}

