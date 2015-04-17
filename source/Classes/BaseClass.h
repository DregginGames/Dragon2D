#pragma once

#include "base.h"
#include "ScriptLibHelper.h"

namespace Dragon2D {

	template<class T>
	std::shared_ptr<T> NewD2DObject() { return std::shared_ptr<T>(new T); }

	//This Define wich creates the necersary types for each class. Use this for game-object classes (BaseClass and children).
	//syntax: D2DCLASS(Classname, Baseclass1, Baseclass2, ...)
#define D2DCLASS(name,...) \
	class name; \
	typedef std::shared_ptr<name> name##Ptr; /*Pointertype for this class */\
	class name : __VA_ARGS__ /* Class-header for this class*/

	//class: BaseClass
	//note: BaseClass for all game specific thigs
	D2DCLASS(BaseClass, public std::enable_shared_from_this<BaseClass>)
	{
	public:

		//constructor: BaseClass
		//note: Standard Constructor. 
		BaseClass();

		//destructor: ~BaseClass()
		//note: standard destructor
		virtual ~BaseClass();

		//function: Update
		//note: Updates this Object and its children
		virtual void Update();
		//function: Render
		//note: Renders this Object and its children
		virtual void Render();

		//function: AddChild
		//note: Adds a Chilobject to this class
		//param:	child: The child to add to object
		virtual void AddChild(BaseClassPtr child);
		//function: RemoveChild
		//note: Removes a child from this class
		//param:	child: The child to remove
		virtual void RemoveChild(BaseClassPtr child);

		//function: RemoveChild
		//note: Sets the parent of this object
		//param:	parent: the object to set as parent
		virtual void SetParent(BaseClassPtr parent);
		//function: GetParent
		//note: Returns the parent-class 
		virtual BaseClassPtr GetParent() const;

		//function: SetRenderLayer
		//note: Sets the render layer of this object
		//param:	layer: layer to render on. must be >= 0
		virtual void SetRenderLayer(unsigned int layer);

		//function: GetRenderLayer
		//note: Returns the render layer of this object
		virtual unsigned int GetRenderLayer() const;

		//function: Ptr
		//note: Returns a pointer to this object
		virtual BaseClassPtr Ptr();

		//function: RegisterInputHooks
		//note: Called when the objects input-hooks can be registerd
		virtual void RegisterInputHooks();

		//function: RemoveInputHooks
		//note: Called when the objects input-hooks can be removed
		virtual void RemoveInputHooks();

		//function: IncTick()
		//note: Called once by the GameManager, increases the ticks that elapsed since the gameManager started 
		static void IncTick();

	protected:
		//var: parent. Parent of this object
		BaseClassPtr parent;
		//var: children. Children of this object
		std::vector<BaseClassPtr> children;

		//var: renderLayer. Layer of the object. REALLY IMPORTAND for render-order.
		unsigned int renderLayer;

		//var: ticks. Ticks since the GameManager started
		static long int ticks;
		//var: hasInputsRegisterd. Helper to manage post-game-manager-call input hug registration and removal
		bool hasInputsRegisterd;
	};

	D2DCLASS_SCRIPTINFO_BEGIN_GENERAL_GAMECLASS(BaseClass)
		D2DCLASS_SCRIPTINFO_MEMBER(BaseClass, Update)
		D2DCLASS_SCRIPTINFO_MEMBER(BaseClass, Render)
		D2DCLASS_SCRIPTINFO_MEMBER(BaseClass, AddChild)
		D2DCLASS_SCRIPTINFO_MEMBER(BaseClass, RemoveChild)
		D2DCLASS_SCRIPTINFO_MEMBER(BaseClass, SetParent)
		D2DCLASS_SCRIPTINFO_MEMBER(BaseClass, GetParent)
	D2DCLASS_SCRIPTINFO_END
};
