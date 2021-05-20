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
		import java.util.HashMap;
		import java.util.List;
		import java.util.Map;
		
		import org.eclipse.emf.ecore.EObject;
		
		import ca.mcgill.sel.core.*;
		import ca.mcgill.sel.core.perspective.*;
		import ca.mcgill.sel.ram.ui.perspective.*;
		import ca.mcgill.sel.ram.ui.perspective.controller.*;
		
		import «language.rootPackage».*;
		import «language.controllerPackage».*;
		import «language.utilPackage».*;
		
		public class Redefined«language.name»Action {
			«FOR action : perspective.actions»
				«IF action.langActionType == LanguageActionType.CREATE &&
				action.roleName.equals(language.roleName)»
					public static EObject «action.name»(COREPerspective perspective, COREScene scene, String currentRole, 
						boolean isFacadeCall, «action.typeParameters») {
						
						List<EObject> createSecondaryEffects = new ArrayList<EObject>();
						«FOR createEffect : action.createEffects»
							createSecondaryEffects.add(«createEffect.languageElement»);
						«ENDFOR»
						
						// record existing elements.
						ModelElementStatus.INSTANCE.setMainExistingElements(owner, «action.metaclassObject»);
						ModelElementStatus.INSTANCE.setOtherExistingElements(owner, createSecondaryEffects);
						
						// primary language action to create a new class
						«action.methodCall»;
					
						// retrieve the new element
						EObject newElement = ModelElementStatus.INSTANCE.getNewElement(owner, «action.metaclassObject»);
						
						// get other new elements for each language element
						Map<EObject, Collection<EObject>> a = ModelElementStatus.INSTANCE.getOtherNewElements(owner, createSecondaryEffects);
						Map<EObject, Collection<EObject>> after = new HashMap<EObject, Collection<EObject>>(a);
					
						if (!isFacadeCall) {
							createOtherElementsFor«action.metaclassName»(perspective, scene, currentRole, newElement,
							 	«action.methodParameter»);						
						}
						«IF action.createEffects.size > 0» 	
							HandleSecondaryEffect.INSTANCE.createSecondaryEffects(perspective, scene, currentRole, after, 
								«action.methodParameter»);
						«ENDIF»
					
					//		try {
					//			createOtherElementsForLEMA1(perspective, scene, newElement, currentRole, owner, name);
					//		} catch (PerspectiveException e) {
					//			RamApp.getActiveScene().displayPopup(e.getMessage());
					//		}
					
					return newElement;
					
					
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
							
							// C1/C9
							case CAN_CREATE:
							case CAN_CREATE_OR_USE_NON_MAPPED:
								canCreateOrUseNonMappedElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
										otherLE, «action.methodParameter»);
								break;
					
							// C2/C10
							case CREATE:
							case CREATE_OR_USE_NON_MAPPED:
								createOrUseNonMappedElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
										otherLE, «action.methodParameter»);
								break;
					
							// C3/C11
							case CAN_CREATE_MANY:
							case CAN_CREATE_OR_USE_NON_MAPPED_MANY:
								canCreateOrUseNonMappedManyElementsFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName,
										otherRoleName, otherLE, «action.methodParameter»);
								break;
					
							// C4/C12
							case CREATE_AT_LEAST_ONE:
							case CREATE_OR_USE_NON_MAPPED_AT_LEAST_ONE:
								createOrUseNonMappedAtLeastOneElementFor«action.metaclassName»(perspective, mappingType, scene, currentElement, currentRoleName,
										otherRoleName, otherLE, «action.methodParameter»);
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
					
							}
						}
					}
					
					/**
					 * (C1/C5): This method optionally creates a new element and then
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
					private static void canCreateOrUseElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
							EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
					
						EObject otherElement = null;
						boolean otherExist = true;
						// Ask the user whether to create other model element and then establish
						// the MEM
						boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
						if (isCreateMapping) {
							otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
							if (otherElement == null) {
								otherExist = false;
								otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, «action.methodParameter»);
							}
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							// save the recent changes
							BasePerspectiveController.saveModel(scene);
							if(!otherExist) {
								owner = otherElement.eContainer();
								createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);	
							}
						}
					}
					
					
					/**
					 * (C2/C6): This method proactively creates a new element and then
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
					private static void createOrUseElementFor«action.metaclassName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement,
							String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
					
						EObject otherElement = null;
						boolean otherExist = true;
						otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
						if (otherElement == null) {
							otherExist = false;
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
								«action.methodParameter»);
						}
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						BasePerspectiveController.saveModel(scene);
						if (!otherExist) {
							owner = otherElement.eContainer();
							createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);
						}
						
					}
					
					/**
					 * (C3/C7): This method can create or use an existing elements to
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
								BasePerspectiveController.saveModel(scene);
								numberOfMappings--;
							}
						}
						for (int count = 0; count < numberOfMappings; count++) {
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
														«action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							BasePerspectiveController.saveModel(scene);
							owner = otherElement.eContainer();
							createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);
						}
					}
					
					/**
					 * (C4/C8): This method proactively creates or uses an existing element,
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
								BasePerspectiveController.saveModel(scene);
								numberOfMappings--;
							}
						}
						for (int count = 0; count < numberOfMappings; count++) {
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
														«action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							BasePerspectiveController.saveModel(scene);
							owner = otherElement.eContainer();
							createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);
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
						boolean otherExist = true;
						boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
						if (isCreateMapping) {
							otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
							// creates new element if other element does not exist or it is
							// already mapped.
							if (otherElement == null || COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherElement).size() != 0) {
								otherExist = false;
								otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
															«action.methodParameter»);
							}
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							BasePerspectiveController.saveModel(scene);
							if (!otherExist) {
								owner = otherElement.eContainer();
								createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);
							}
							
					
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
						BasePerspectiveController.saveModel(scene);
						// stop the recursion if other element exists.
						if (!otherExist) {
							owner = otherElement.eContainer();
							createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);
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
						  			BasePerspectiveController.saveModel(scene);
									numberOfMappings--;
								}
							}
						}
						for (int count = 0; count < numberOfMappings; count++) {
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
														«action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						  	BasePerspectiveController.saveModel(scene);
						  	owner = otherElement.eContainer();
							createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);
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
							  		BasePerspectiveController.saveModel(scene);
									numberOfMappings--;
								}
							}
						}
						for (int count = 0; count < numberOfMappings; count++) {
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.metaclassName»(perspective, otherLE, otherRoleName, scene, 
														«action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						  	BasePerspectiveController.saveModel(scene);
						  	owner = otherElement.eContainer();
							createOtherElementsFor«action.metaclassName»(perspective, scene, otherRoleName, otherElement, «action.methodParameter»);
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
						
						«IF action.deleteEffects.size > 0»
							HandleSecondaryEffect.INSTANCE.deleteSecondaryEffects(perspective, scene, currentRole, deleteSecondaryEffects);
						«ENDIF»
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