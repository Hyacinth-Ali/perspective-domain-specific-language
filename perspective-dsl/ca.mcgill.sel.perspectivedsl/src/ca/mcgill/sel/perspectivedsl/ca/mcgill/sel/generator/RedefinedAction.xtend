package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.PerspectiveActionType
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Language
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.LanguageActionType

class RedefinedAction {
	
	def static compileActions(Perspective perspective, Language language) {
		
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase»;
		
		import java.util.ArrayList;
		import java.util.Collection;
		import java.util.List;
		import java.util.Map;
		
		import org.eclipse.emf.ecore.EObject;
		
		import ca.mcgill.sel.core.*;
		import ca.mcgill.sel.core.perspective.*;
		import ca.mcgill.sel.ram.ui.perspective.*;
		import ca.mcgill.sel.ram.ui.perspective.controller.*;
		
		import «language.rootPackage».*;
		import «language.controllerPackage».*;
		import «language.facadeActionPackage».*;
		
		public class Redefined«language.name»Action {
		«FOR action : perspective.actions»
			«IF action.langActionType == LanguageActionType.CREATE &&
			action.roleName.equals(language.roleName)»
				public static void «action.name»(COREPerspective perspective, COREScene scene, String currentRole, 
					«action.typeParameters») {
					
					List<EObject> createSecondaryEffects = new ArrayList<EObject>();
					«FOR createEffect : action.createEffects»
						createSecondaryEffects.add(«createEffect.languageElement»);
					«ENDFOR»
					
					// record existing elements.
					BaseFacade.INSTANCE.setMainExistingElements(owner, «action.metaclassObject»);
					BaseFacade.INSTANCE.setOtherExistingElements(owner, createSecondaryEffects);
					
					// primary language action to create a new class
					«action.methodCall»;
				
					// retrieve the new element
					EObject newElement = BaseFacade.INSTANCE.getNewElement(owner, «action.metaclassObject»);
					
					// get other new elements foe each language element
					Map<EObject, Collection<EObject>> after = BaseFacade.INSTANCE.getOtherNewElements(owner, createSecondaryEffects);
				
					createOtherElementsFor«action.metaclassName»(perspective, scene, currentRole, newElement,
					 	«action.methodParameter»);
					 	
					HandleSecondaryEffect.INSTANCE.createSecondaryEffects(perspective, scene, currentRole, after, 
						«action.methodParameter»);
				
				//		try {
				//			createOtherElementsForLEMA1(perspective, scene, newElement, currentRole, owner, name);
				//		} catch (PerspectiveException e) {
				//			RamApp.getActiveScene().displayPopup(e.getMessage());
				//		}
				
				
				}
				
				public static void createOtherElementsFor«action.metaclassName»(COREPerspective perspective, COREScene scene, String currentRoleName,
						EObject currentElement, «action.typeParameters») throws PerspectiveException {
				
					List<CORELanguageElementMapping> mappingTypes = COREPerspectiveUtil.INSTANCE.getMappingTypes(perspective,
							currentElement.eClass(), currentRoleName);
					for (CORELanguageElementMapping mappingType : mappingTypes) {
						List<COREModelElementMapping> mappings = COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene,
								currentElement);
				
						String otherRoleName = COREPerspectiveUtil.INSTANCE.getOtherRoleName(mappingType, currentRoleName);
				
						// the metaclass of the element to be created.
						EObject otherLE = COREPerspectiveUtil.INSTANCE
								.getOtherLanguageElements(mappingType, currentElement.eClass(), currentRoleName).get(0);
				
						ActionType actionType = TemplateType.INSTANCE.getCreateType(mappingType, currentRoleName);
				
						// check that the number of existing mappings is not zero.
						if (mappings.size() != 0) {
							continue;
						}
						switch (actionType) {
				
						// C1
						case CAN_CREATE:
							canCreateElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, 
									«action.methodParameter»);
							break;
				
						// C2
						case CREATE:
							createElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
									«action.methodParameter»);
							break;
				
						// C3
						case CAN_CREATE_MANY:
							canCreateManyElementsFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, 
									«action.methodParameter»);
							break;
				
						// C4
						case CREATE_AT_LEAST_ONE:
							createAtLeastOneElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
									«action.methodParameter»);
							break;
				
						// C5
						case CAN_CREATE_OR_USE:
							canCreateOrUseElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
									«action.methodParameter»);
							break;
				
						// C6
						case CREATE_OR_USE:
							createOrUseElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, 
									«action.methodParameter»);
							break;
				
						// C7
						case CAN_CREATE_OR_USE_MANY:
							canCreateOrUseManyElementsFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
									«action.methodParameter»);
							break;
				
						// C8
						case CREATE_OR_USE_AT_LEAST_ONE:
							createOrUseAtLeastOneElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, 
									«action.methodParameter»);
							break;
				
						// C9
						case CAN_CREATE_OR_USE_NON_MAPPED:
							canCreateOrUseNonMappedElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
									otherLE, «action.methodParameter»);
							break;
				
						// C10
						case CREATE_OR_USE_NON_MAPPED:
							createOrUseNonMappedElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
									otherLE, «action.methodParameter»);
							break;
				
						// C11
						case CAN_CREATE_OR_USE_NON_MAPPED_MANY:
							canCreateOrUseNonMappedManyElementsFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName,
									otherRoleName, otherLE, «action.methodParameter»);
							break;
				
						// C12
						case CREATE_OR_USE_NON_MAPPED_AT_LEAST_ONE:
							createOrUseNonMappedAtLeastOneElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName,
									otherRoleName, otherLE, «action.methodParameter»);
							break;
				
						}
					}
				}
				
				/**
				 * (C1): This method optionally creates a new element and then
				 * establishes model element mapping between the "element" parameter and the
				 * new element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void canCreateElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
					EObject otherElement = null;
					// Ask the user whether to create other model element and then establish
					// the MEM
					boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
					if (isCreateMapping) {
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
							«action.methodParameter»);
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						// save the recent changes
						// BasePerspectiveController.saveModel(scene);
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				
				/**
				 * (C2): This method proactively creates a new element and then
				 * establishes model element mapping between the "element" parameter and the
				 * new element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void createElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement,
						String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
					EObject otherElement = null;
					otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
												«action.methodParameter»);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//		BasePerspectiveController.saveModel(scene);
					createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), name);
				}
				
				/**
				 * (C3): This method can create many elements and then
				 * establishes model element mapping between the "element" parameter and each of
				 * the new elements. The user determines the number of new elements that can be created.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void canCreateManyElementsFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
					EObject otherElement = null;
					int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappings();
					for (int count = 0; count < numberOfMappings; count++) {
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//			BasePerspectiveController.saveModel(scene);
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				/**
				 * (C4): This method proactively creates at least one element and then
				 * establishes model element mapping between the "element" parameter and the
				 * new element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void createAtLeastOneElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
					EObject otherElement = null;
					int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappingsAtLeastOne();
					for (int count = 0; count < numberOfMappings; count++) {
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//			BasePerspectiveController.saveModel(scene);
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				/**
				 * (C5): This method can create or use an existing element to
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
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void canCreateOrUseElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
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
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
														«action.methodParameter»);
						}
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//			BasePerspectiveController.saveModel(scene);
						if (!otherExist) {
							createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
									name);
						}
					}
				}
				
				/**
				 * (C6): This method proactively creates or uses an existing element to
				 * establishes model element mapping between the "element" parameter and the
				 * new element or the existing element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void createOrUseElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
					EObject otherElement = null;
					boolean otherExist = true;
					// Check if a corresponding element exist, either mapped or not
					otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
					if (otherElement == null) {
						otherExist = false;
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
					}
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//		BasePerspectiveController.saveModel(scene);
					if (!otherExist) {
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				/**
				 * (C7): This method can create or use an existing elements to
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
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void canCreateOrUseManyElementsFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
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
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//	  		BasePerspectiveController.saveModel(scene);
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				/**
				 * (C8): This method proactively creates or uses an existing element,
				 * at least one element, to establishes model element mapping between the 
				 * "element" parameter and the new element or the existing element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void createOrUseAtLeastOneElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
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
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//	  		BasePerspectiveController.saveModel(scene);
						// call recursive method since a new element was used in the mapping
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				/**
				 * (C9): This method can create or use non-mapped existing element to
				 * establishes model element mapping between the "element" parameter and the
				 * new element or the existing element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void canCreateOrUseNonMappedElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
					EObject otherElement = null;
					boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
					if (isCreateMapping) {
						otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
						// creates new element if other element does not exist or it is
						// already mapped.
						if (otherElement == null
								|| COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherElement).size() != 0) {
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
														«action.methodParameter»);
						}
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//				BasePerspectiveController.saveModel(scene);
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
				
					}
				}
				
				/**
				 * (C10): This method proactively creates or uses non-mapped existing element to
				 * establishes model element mapping between the "element" parameter and the
				 * new element or the existing element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void createOrUseNonMappedElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
						EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
				
					EObject otherElement = null;
					boolean otherExist = true;
					otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
				
					// create other element if the corresponding element is null
					// or mapped.
					if (otherElement == null || COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherElement).size() > 0) {
						otherExist = false;
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
				
					}
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//		BasePerspectiveController.saveModel(scene);
					// stop the recursion if other element exists.
					if (!otherExist) {
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				/**
				 * (C11): This method can create many elements or use non-mapped 
				 * existing elements to establish model element mappings between the "element" parameter 
				 * and each of the new element or the existing element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void canCreateOrUseNonMappedManyElementsFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType,
						COREScene scene, EObject currentElement, String currentRoleName, String otherRoleName,
						EObject otherLE, «action.typeParameters») {
				
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
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//	  		BasePerspectiveController.saveModel(scene);
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
				/**
				 * (C12): This method proactively creates many elements or uses non-mapped 
				 * existing elements to establish model element mappings between the "element" parameter 
				 * and each of the new element or the existing element.
				 * 
				 * @author Hyacinth Ali
				 * 
				 * @param perspective
				 * @param mappingType
				 * @param scene
				 * @param currentElement
				 * @param currentRoleName 
				 * @param otherRoleName
				 * @param otherLE
				 * @param currentOwner
				 * @param name
				 */
				private static void createOrUseNonMappedAtLeastOneElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType,
						COREScene scene, EObject currentElement, String currentRoleName, String otherRoleName,
						EObject otherLE, «action.typeParameters») {
				
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
						otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
													«action.methodParameter»);
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
				//	  		BasePerspectiveController.saveModel(scene);
						createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(),
								name);
					}
				}
				
			«ELSEIF action.langActionType == LanguageActionType.DELETE &&
			action.roleName.equals(language.roleName)»
				public static void «action.name»(COREPerspective perspective, COREScene scene, String currentRole, «action.typeParameters») {
					
					List<EObject> deleteSecondaryEffects = new ArrayList<EObject>();
					«FOR deleteEffect : action.deleteEffects»
						deleteSecondaryEffects.add(«deleteEffect.element»);
					«ENDFOR»
										
					«action.methodCall»;
					deleteOtherElementsFor«action.metaclassName»(perspective, scene, currentRole, «action.methodParameter»);
					
					if (deleteSecondaryEffects != null) {
						HandleSecondaryEffect.INSTANCE.deleteSecondaryEffects(perspective, scene, currentRole, deleteSecondaryEffects);
					}
				}
				
				public static void deleteOtherElementsFor«action.metaclassName»(COREPerspective perspective, COREScene scene, String currentRole, «action.typeParameters») {
				
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
						String otherRoleName = COREPerspectiveUtil.INSTANCE.getOtherRoleName(mappingType, currentRole);
						switch (deleteType) {
				
						case DELETE_OTHERS:
							«language.name»FacadeAction.deleteModelElement(otherElement);
							deleteOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement);
							break;
				
						case DELETE_SINGLEMAPPED:
							List<COREModelElementMapping> otherMappings = COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene,
									otherElement);
							if (otherMappings.size() == 0) {
								«language.name»FacadeAction.deleteModelElement(otherElement);
								deleteOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement);
							}
							break;
						}
					}
				}
				
			«ENDIF»
			 	        
			

		«ENDFOR»
		}
		

		'''
	}
}