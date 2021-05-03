package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

class RedefinedAction {
	
	def static compile() {
		
		'''
		
			public void createNewA1(COREPerspective perspective, COREScene scene, String currentRole, AModel owner,
					String name) {
				// a list to contain all the newly created classes
				List<EObject> elements = new ArrayList<EObject>();
				// a list to contain all the existing classes
				List<EObject> initialElements = new ArrayList<EObject>();
				initialElements.addAll(owner.getA1s());
		
				// primary language action to create a new class
				AModelController.getInstance().createA1(owner, name);
		
				// retrieve the new element
				elements.addAll(owner.getA1s());
				elements.removeAll(initialElements);
				EObject newElement = elements.get(0);
		
				createOtherElementsForA1(perspective, scene, currentRole, newElement, owner, name);
		
		//		try {
		//			createOtherElementsForLEMA1(perspective, scene, newElement, currentRole, owner, name);
		//		} catch (PerspectiveException e) {
		//			RamApp.getActiveScene().displayPopup(e.getMessage());
		//		}
		
				newElements.clear();
		
			}
		
			private void createOtherElementsForA1(COREPerspective perspective, COREScene scene, String currentRoleName,
					EObject currentElement, EObject currentOwner, String name) throws PerspectiveException {
		
				List<CORELanguageElementMapping> mappingTypes = COREPerspectiveUtil.INSTANCE.getMappingTypes(perspective,
						currentElement.eClass(), currentRoleName);
				for (CORELanguageElementMapping mappingType : mappingTypes) {
					List<COREModelElementMapping> mappings = COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene,
							currentElement);
		
					// other role names, i.e., excluding the current role
					String otherRoleName = COREPerspectiveUtil.INSTANCE.getOtherRoleName(perspective, currentRoleName);
		
					// the metaclass of the element to be created.
					EObject otherLE = COREPerspectiveUtil.INSTANCE
							.getOtherLanguageElements(mappingType, currentElement.eClass(), currentRoleName).get(0);
		
					ActionType actionType = TemplateType.INSTANCE.getCreateType(mappingType, currentRoleName);
		
					// check that the number of existing mappings is not zero.
					if (mappings.size() != 0) {
						break;
					}
					switch (actionType) {
		
					// C1
					case CAN_CREATE:
						canCreateElement(perspective, mappingType, scene, currentElement, null, otherRoleName, otherLE, currentOwner, name);
						break;
		
					// C2
					case CREATE:
						createElement(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
								currentOwner, name);
						break;
		
					// C3
					case CAN_CREATE_MANY:
						canCreateManyElements(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, currentOwner, name);
						break;
		
					// C4
					case CREATE_AT_LEAST_ONE:
						createAtLeastOneElement(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
								currentOwner, name);
						break;
		
					// C5
					case CAN_CREATE_OR_USE:
						canCreateOrUseElement(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
								currentOwner, name);
						break;
		
					// C6
					case CREATE_OR_USE:
						createOrUseElement(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, currentOwner, name);
						break;
		
					// C7
					case CAN_CREATE_OR_USE_MANY:
						canCreateOrUseManyElements(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
								currentOwner, name);
						break;
		
					// C8
					case CREATE_OR_USE_AT_LEAST_ONE:
						createOrUseAtLeastOneElement(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
								otherLE, currentOwner, name);
						break;
		
					// C9
					case CAN_CREATE_OR_USE_NON_MAPPED:
						canCreateOrUseNonMappedElement(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
								otherLE, currentOwner, name);
						break;
		
					// C10
					case CREATE_OR_USE_NON_MAPPED:
						createOrUseNonMappedElement(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
								otherLE, currentOwner, name);
						break;
		
					// C11
					case CAN_CREATE_OR_USE_NON_MAPPED_MANY:
						canCreateOrUseNonMappedManyElements(perspective, mappingType, scene, currentElement, currentRoleName,
								otherRoleName, otherLE, currentOwner, name);
						break;
		
					// C12
					case CREATE_OR_USE_NON_MAPPED_AT_LEAST_ONE:
						createOrUseNonMappedAtLeastOneElement(perspective, mappingType, scene, currentElement, currentRoleName,
								otherRoleName, otherLE, currentOwner, name);
						break;
		
					}
				}
			}
		
			/**
			 * CAN_CREATE (C1): This method optionally creates a new element and then
			 * establishes model element mapping between the "element" parameter and the
			 * new element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void canCreateElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				// Ask the user whether to create other model element and then establish
				// the MEM
				boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
				if (isCreateMapping) {
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
					// save the recent changes
		//			BasePerspectiveController.saveModel(scene);
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			
			/**
			 * CAN_CREATE (C2): This method proactively creates a new element and then
			 * establishes model element mapping between the "element" parameter and the
			 * new element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void createElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement,
					String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName, name,
						scene);
				COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//		BasePerspectiveController.saveModel(scene);
				createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), name);
			}
		
			/**
			 * CAN_CREATE (C3): This method can create many elements and then
			 * establishes model element mapping between the "element" parameter and each of
			 * the new elements. The user determines the number of new elements that can be created.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void canCreateManyElements(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappings();
				for (int count = 0; count < numberOfMappings; count++) {
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//			BasePerspectiveController.saveModel(scene);
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			/**
			 * CAN_CREATE (C4): This method proactively creates at least one element and then
			 * establishes model element mapping between the "element" parameter and the
			 * new element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void createAtLeastOneElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappingsAtLeastOne();
				for (int count = 0; count < numberOfMappings; count++) {
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//			BasePerspectiveController.saveModel(scene);
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			/**
			 * CAN_CREATE (C5): This method can create or use an existing element to
			 * establishes model element mapping between the "element" parameter and the
			 * new element or the existing element. The user determines whether the method
			 * should establish the model element mapping.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void canCreateOrUseElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				boolean otherExist = true;
				// Ask user whether to create a mapping
				boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
				if (isCreateMapping) {
					// Check if a corresponding element exist, either mapped or not
		//			otherElement = QueryAction.INSTANCE.findCorrespondingElementByName(scene, otherElement, toCreateRoleName);
					otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
					if (otherElement == null) {
						otherExist = false;
						otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner,
								otherRoleName, name, scene);
					}
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//			BasePerspectiveController.saveModel(scene);
					if (!otherExist) {
						createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
			}
		
			/**
			 * CAN_CREATE (C6): This method proactively creates or uses an existing element to
			 * establishes model element mapping between the "element" parameter and the
			 * new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void createOrUseElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				boolean otherExist = true;
				// Check if a corresponding element exist, either mapped or not
				otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
				if (otherElement == null) {
					otherExist = false;
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
				}
				COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//		BasePerspectiveController.saveModel(scene);
				if (!otherExist) {
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			/**
			 * CAN_CREATE (C7): This method can create or use an existing elements to
			 * establish model element mappings between the "element" parameter and each of the
			 * new element or existing elements. Similarly, the usser decides if the method should
			 * create the mappings.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void canCreateOrUseManyElements(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				// Ask user how many mappings to create
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappings();
				List<EObject> otherElements = QueryAction.INSTANCE.findCorrespondingElements(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						otherElement = existingElement;
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//	  			BasePerspectiveController.saveModel(scene);
		//				No need for recursive call since this is a mapping with an existing element.
						numberOfMappings--;
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//	  		BasePerspectiveController.saveModel(scene);
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			/**
			 * CAN_CREATE (C8): This method proactively creates or uses an existing element,
			 * at least one element, to establishes model element mapping between the 
			 * "element" parameter and the new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void createOrUseAtLeastOneElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				// Ask user how many mappings to create
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappingsAtLeastOne();
				List<EObject> otherElements = QueryAction.INSTANCE.findCorrespondingElements(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						otherElement = existingElement;
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//	  			BasePerspectiveController.saveModel(scene);
		//				No need for recursive call since this is a mapping with an existing element.
						numberOfMappings--;
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//	  		BasePerspectiveController.saveModel(scene);
					// call recursive method since a new element was used in the mapping
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			/**
			 * CAN_CREATE (C9): This method can create or use non-mapped existing element to
			 * establishes model element mapping between the "element" parameter and the
			 * new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void canCreateOrUseNonMappedElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
				if (isCreateMapping) {
					otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
					// creates new element if other element does not exist or it is
					// already mapped.
					if (otherElement == null
							|| COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherElement).size() != 0) {
						otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner,
								otherRoleName, name, scene);
					}
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//				BasePerspectiveController.saveModel(scene);
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
		
				}
			}
		
			/**
			 * CAN_CREATE (C10): This method proactively creates or uses non-mapped existing element to
			 * establishes model element mapping between the "element" parameter and the
			 * new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void createOrUseNonMappedElement(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
					EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				boolean otherExist = true;
				otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
		
				// create other element if the corresponding element is null
				// or mapped.
				if (otherElement == null || COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherElement).size() > 0) {
					otherExist = false;
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
		
				}
				COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//		BasePerspectiveController.saveModel(scene);
				// stop the recursion if other element exists.
				if (!otherExist) {
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			/**
			 * CAN_CREATE (C11): This method can create many elements or use non-mapped 
			 * existing elements to establish model element mappings between the "element" parameter 
			 * and each of the new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void canCreateOrUseNonMappedManyElements(COREPerspective perspective, CORELanguageElementMapping mappingType,
					COREScene scene, EObject currentElement, String currentRoleName, String otherRoleName,
					EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappings();
				List<EObject> otherElements = QueryAction.INSTANCE.findCorrespondingElements(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
				// create mapping for each corresponding element which is not mapped
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						if (COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, existingElement).size() == 0) {
							otherElement = existingElement;
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//	  			BasePerspectiveController.saveModel(scene);
		//				No need for recursive call since this is a mapping with an existing element.
							numberOfMappings--;
						}
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//	  		BasePerspectiveController.saveModel(scene);
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			/**
			 * CAN_CREATE (C12): This method proactively creates many elements or uses non-mapped 
			 * existing elements to establish model element mappings between the "element" parameter 
			 * and each of the new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param currentRoleName TODO
			 * @param otherRoleName
			 * @param otherLE
			 * @param currentOwner
			 * @param name
			 */
			private void createOrUseNonMappedAtLeastOneElement(COREPerspective perspective, CORELanguageElementMapping mappingType,
					COREScene scene, EObject currentElement, String currentRoleName, String otherRoleName,
					EObject otherLE, EObject currentOwner, String name) {
		
				EObject otherElement = null;
				// Ask user how many mappings to create (at least one)
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappingsAtLeastOne();
				List<EObject> otherElements = QueryAction.INSTANCE.findCorrespondingElements(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
				// create mapping for each corresponding element which is not mapped
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						if (COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, existingElement).size() == 0) {
							otherElement = existingElement;
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//		  			BasePerspectiveController.saveModel(scene);
		//					No need for recursive call since this is a mapping with an existing element.
							numberOfMappings--;
						}
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherElement = TestFacadeAction.createOtherElementsForA1(perspective, otherLE, currentOwner, otherRoleName,
							name, scene);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
		//	  		BasePerspectiveController.saveModel(scene);
					createOtherElementsForA1(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
							name);
				}
			}
		
			public void deleteA1(COREPerspective perspective, COREScene scene, String currentRole, A1 a1) {
				AModelController.getInstance().removeA1(a1);
				deleteOtherElementsForA1(perspective, scene, currentRole, a1);
			}
		
			private void deleteOtherElementsForA1(COREPerspective perspective, COREScene scene, String currentRole, EObject currentElement) {
		
				List<COREModelElementMapping> mappings = COREPerspectiveUtil.INSTANCE.getMappings(scene, currentElement);
				// Traditional for loop is used here to avoid
				// ConcurrentModificationException
				for (int i = 0; i < mappings.size(); i++) {
					COREModelElementMapping mapping = mappings.get(i);
					EObject otherElement = COREPerspectiveUtil.INSTANCE.getOtherElement(mapping, currentElement);
					CORELanguageElementMapping mappingType = COREPerspectiveUtil.INSTANCE.getMappingType(perspective, mapping);
					
					// get the delete action type
					ActionType deleteType = null;
					for (MappingEnd mappingEnd : mappingType.getMappingEnds()) {
						if (mappingEnd.getRoleName().equals(currentRole)) {
							deleteType = TemplateType.INSTANCE.getDeleteType(mappingEnd);
							break;
						}
					}
		
					// remove the mapping
					BasePerspectiveController.removeMapping(mapping);
					
					if (deleteType == null) {
						return;
					}
		
					// get other role name
					String otherRoleName = COREPerspectiveUtil.INSTANCE.getOtherRoleName(perspective, currentRole);
					switch (deleteType) {
		
					case DELETE_OTHERS:
						TestFacadeAction.deleteModelElement(otherElement);
						deleteOtherElementsForA1(perspective, scene, otherRoleName, otherElement);
						break;
		
					case DELETE_SINGLEMAPPED:
						List<COREModelElementMapping> otherMappings = COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene,
								otherElement);
						if (otherMappings.size() == 0) {
							TestFacadeAction.deleteModelElement(otherElement);
							deleteOtherElementsForA1(perspective, scene, otherRoleName, otherElement);
						}
						break;
					}
				}
			}
		'''
	}
}