/**
	d2d.core.callback holds the types and few functions needed for Dragon2Ds callback system
*/
module d2d.core.callback;

import d2d.core.base;

/// basic callback, retun is the success of the callback
alias Callback = bool function();

/// Callback on object operations
alias ObjectCallback = bool function(Base obj);
