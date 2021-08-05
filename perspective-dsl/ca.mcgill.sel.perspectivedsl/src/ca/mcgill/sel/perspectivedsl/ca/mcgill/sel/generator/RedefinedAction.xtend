package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Language
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.LanguageActionType
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.CreateAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.DeleteAction

class RedefinedAction {
	
	var static count = 0;

    private def static void resetCounter() {
       count = 0;
    }

   private def static void counter() {
       count++;
   }
	
	def static compileActions(Perspective perspective, Language language) {
		
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase»;
		
		import java.util.ArrayList;
		import java.util.Collection;
		import java.util.HashMap;
		import java.util.List;
		import java.util.Map;
		
		import org.eclipse.emf.common.util.BasicEList;
		import org.eclipse.emf.common.util.EList;
		import org.eclipse.emf.ecore.EObject;
		
		import ca.mcgill.sel.core.*;
		import ca.mcgill.sel.core.perspective.*;
		import ca.mcgill.sel.ram.ui.perspective.*;
		
		import «language.rootPackage».*;
		import «language.controllerPackage».*;
		«FOR rootPackage : language.otherRootPackages»
			import «rootPackage.otherRootPackage».*;
		«ENDFOR»
		«FOR explicitPackage : language.explicitPackages»
			import «explicitPackage.explicitPackage»;
		«ENDFOR»
		
		public class «perspective.namePrefix»Redefined«language.name»Action {
			«FOR action : language.actions»
				«IF action instanceof CreateAction &&
				action.roleName.equals(language.roleName)»
					public static EObject «action.name»(COREPerspective perspective, COREScene scene, String currentRole, 
						«action.typeParameters») {
						
						EObject newElement = null;
						«IF !action.rootElement»
							List<EObject> createSecondaryEffects = new ArrayList<EObject>();
							«FOR createEffect : action.createEffects»
								createSecondaryEffects.add(«createEffect.languageElement»);
							«ENDFOR»
							
							// record existing elements.
							ModelElementStatus.INSTANCE.setMainExistingElements(owner, «action.languageElement»);
							ModelElementStatus.INSTANCE.setOtherExistingElements(owner, createSecondaryEffects);
							
							// primary language action to create a new element
							«action.methodCall»;
						
							// retrieve the new element
							newElement = ModelElementStatus.INSTANCE.getNewElement(owner, «action.languageElement»);
							
							// get other new elements for each language element
							Map<EObject, Collection<EObject>> a = ModelElementStatus.INSTANCE.getOtherNewElements(owner, createSecondaryEffects);
							Map<EObject, Collection<EObject>> after = new HashMap<EObject, Collection<EObject>>(a);
							
							createOtherElementsFor«action.languageElementName»(perspective, scene, currentRole, newElement, owner,
								«action.methodParameter»);
							
							«IF action.createEffects.size > 0» 	
								«action.name»SecondaryEffects(perspective, scene, currentRole, after, owner, 
									«action.methodParameter»);
							«ENDIF»
							
						«ENDIF»
«««						«IF action.rootElement»
«««							// primary language action to create root model element
«««							newElement = «action.methodCall»;
«««
«««							if (!isFacadeCall) {
«««								createOtherElementsFor«action.languageElementName»(perspective, scene, currentRole, newElement, owner,
«««								 	«action.methodParameter»);						
«««							}
«««
«««						«ENDIF»
					
					return newElement;
					
					}
					
					public static void createOtherElementsFor«action.languageElementName»(COREPerspective perspective, COREScene scene, String currentRoleName,
							EObject currentElement, «action.typeParameters») throws PerspectiveException {
					
						List<CORELanguageElementMapping> mappingTypes = COREPerspectiveUtil.INSTANCE.getMappingTypes(perspective,
								currentElement.eClass(), currentRoleName);
						for (CORELanguageElementMapping mappingType : mappingTypes) {
							List<COREModelElementMapping> mappings = COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene,
									currentElement);
						
						if (COREPerspectiveUtil.INSTANCE.mappingsContainsElement(mappings, currentElement)) {
							continue;
						}
						
						MappingEnd currentMappingEnd = COREPerspectiveUtil.INSTANCE.getMappingEnd(mappingType, currentElement.eClass(), currentRoleName);
						MappingEnd otherMappingEnd = COREPerspectiveUtil.INSTANCE.getOtherMappingEnds(currentMappingEnd).get(0);
					
						if (otherMappingEnd.isRootMappingEnd()) {
							CreateModel.createOtherRootModels(perspective, mappingType, scene, currentRoleName, currentElement, name);
						} else {
							createOtherElementsFor«action.languageElementName»(perspective, mappingType, scene, currentRoleName, currentElement, owner,
															 	«action.methodParameter»);
						}
							
						}
					}
					
					public static void createOtherElementsFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene, String currentRoleName,
								EObject currentElement, «action.typeParameters») {
							
						String otherRoleName = COREPerspectiveUtil.INSTANCE.getOtherRoleName(mappingType, currentRoleName);
					
						// the metaclass of the element to be created.
						EObject otherLE = COREPerspectiveUtil.INSTANCE
								.getOtherLanguageElements(mappingType, currentElement.eClass(), currentRoleName).get(0);
					
						ActionType actionType = TemplateType.INSTANCE.getCreateType(mappingType, currentRoleName);

						switch (actionType) {
							
						// C1/C9
						case CAN_CREATE:
						case CAN_CREATE_OR_USE_NON_MAPPED:
							canCreateOrUseNonMappedElementFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
									otherLE, owner, «action.methodParameter»);
							break;
					
						// C2/C10
						case CREATE:
						case CREATE_OR_USE_NON_MAPPED:
							createOrUseNonMappedElementFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName,
									otherLE, owner, «action.methodParameter»);
							break;
					
						// C3/C11
						case CAN_CREATE_MANY:
						case CAN_CREATE_OR_USE_NON_MAPPED_MANY:
							canCreateOrUseNonMappedManyElementsFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName,
									otherRoleName, otherLE, owner, «action.methodParameter»);
							break;
					
						// C4/C12
						case CREATE_AT_LEAST_ONE:
						case CREATE_OR_USE_NON_MAPPED_AT_LEAST_ONE:
							createOrUseNonMappedAtLeastOneElementFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName,
									otherRoleName, otherLE, owner, «action.methodParameter»);
							break;
							
						// C5
						case CAN_CREATE_OR_USE:
							canCreateOrUseElementFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
									owner, «action.methodParameter»);
							break;
					
						// C6
						case CREATE_OR_USE:
							createOrUseElementFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, 
									owner, «action.methodParameter»);
							break;
					
						// C7
						case CAN_CREATE_OR_USE_MANY:
							canCreateOrUseManyElementsFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE,
									owner, «action.methodParameter»);
							break;
					
						// C8
						case CREATE_OR_USE_AT_LEAST_ONE:
							createOrUseAtLeastOneElementFor«action.languageElementName»(perspective, mappingType, scene, currentElement, currentRoleName, otherRoleName, otherLE, 
									owner, «action.methodParameter»);
							break;
								
						default:
							// does nothing
					
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
					private static void canCreateOrUseElementFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
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
								otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, owner, «action.methodParameter»);
							}
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							// save the recent changes
							BasePerspectiveController.saveModel(scene);
							if(!otherExist) {
								createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);	
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
					private static void createOrUseElementFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement,
							String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
					
						EObject otherElement = null;
						boolean otherExist = true;
						otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
						if (otherElement == null) {
							otherExist = false;
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, 
								owner, «action.methodParameter»);
						}
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						BasePerspectiveController.saveModel(scene);
						if (!otherExist) {
							createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);
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
					private static void canCreateOrUseManyElementsFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
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
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, 
														owner, «action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							BasePerspectiveController.saveModel(scene);
							createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);
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
					private static void createOrUseAtLeastOneElementFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
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
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, 
														owner, «action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							BasePerspectiveController.saveModel(scene);
							createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);
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
					private static void canCreateOrUseNonMappedElementFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
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
								otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, 
															owner, «action.methodParameter»);
							}
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
							BasePerspectiveController.saveModel(scene);
							if (!otherExist) {
								createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);
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
					private static void createOrUseNonMappedElementFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, COREScene scene,
							EObject currentElement, String currentRoleName, String otherRoleName, EObject otherLE, «action.typeParameters») {
					
						EObject otherElement = null;
						boolean otherExist = true;
						otherElement = QueryAction.INSTANCE.findCorrespondingElement(scene, mappingType, currentElement.eClass(), currentElement, currentRoleName, otherRoleName);
					
						// create other element if the corresponding element is null
						// or mapped.
						if (otherElement == null || COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherElement).size() > 0) {
							otherExist = false;
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, 
														owner, «action.methodParameter»);
						}
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						BasePerspectiveController.saveModel(scene);
						// stop the recursion if other element exists.
						if (!otherExist) {
							createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);
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
					private static void canCreateOrUseNonMappedManyElementsFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType,
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
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, 
														owner, «action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						  	BasePerspectiveController.saveModel(scene);
						  	createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);
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
					private static void createOrUseNonMappedAtLeastOneElementFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType,
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
							otherElement = «language.name»FacadeAction.createOtherElementsFor«action.languageElementName»(perspective, otherLE, otherRoleName, scene, 
														owner, «action.methodParameter»);
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherElement, false);
						  	BasePerspectiveController.saveModel(scene);
						  	createOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement, otherElement.eContainer(), «action.methodParameter»);
						}
					}
«««				Redefined delete action
				«ELSEIF action instanceof DeleteAction &&
				action.roleName.equals(language.roleName)»
					public static void «action.name»(COREPerspective perspective, COREScene scene, String currentRole, «action.typeParameters») {
											
						«action.methodCall»;
						deleteOtherElementsFor«action.languageElementName»(perspective, scene, currentRole, «action.methodParameter»);
						
						«IF action.deleteEffects.size > 0»
							List<EObject> deleteSecondaryEffects = new ArrayList<EObject>();
							«FOR deleteEffect : action.deleteEffects»
								deleteSecondaryEffects.add(«deleteEffect.element»);
							«ENDFOR»
							«action.name»SecondaryEffects(perspective, scene, currentRole, deleteSecondaryEffects);
						«ENDIF»
					}
					
«««					Delete other elements
					public static void deleteOtherElementsFor«action.languageElementName»(COREPerspective perspective, COREScene scene, String currentRole, «action.typeParameters») {
					
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
								«language.name»FacadeAction.deleteOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement);
								deleteOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement);
								break;
					
							case DELETE_SINGLEMAPPED:
								List<COREModelElementMapping> otherMappings = COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene,
										otherElement);
								if (otherMappings.size() == 0) {
									«language.name»FacadeAction.deleteOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement);
									deleteOtherElementsFor«action.languageElementName»(perspective, scene, otherRoleName, otherElement);
								}
								break;
								
							default:
								// do nothing
							}
						}
					}
					
				«ENDIF»
				
«««				action effects
				«resetCounter»
				«IF action.createEffects.size > 0» 	
					private static void «action.name»SecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole, Map<EObject, Collection<EObject>> after, 
							«action.typeParameters») {
						for (Map.Entry<EObject, Collection<EObject>> e : after.entrySet()) {
							Collection<EObject> newElements = e.getValue();
							for (EObject newElement : newElements) {
								«FOR createEffect : action.createEffects»
									«IF count === 0»
										if (newElement.eClass().equals(«createEffect.languageElement»)) {
											«FOR m : createEffect.mappings»
												«m.mapping»;
											«ENDFOR»
														
											// Call the respective redefined recursive method
											«createEffect.methodCall»;
										}
									«ENDIF»
									«IF count > 0»
										else if (newElement.eClass().equals(«createEffect.languageElement»)) {
											«FOR m : createEffect.mappings»
												«m.mapping»;
											«ENDFOR»
												
											// Call the respective redefined recursive method
											«createEffect.methodCall»;
											}
									«ENDIF»
									«counter»
								«ENDFOR»
							}
						}
					}
				«ENDIF»
				«resetCounter»
				«IF action.deleteEffects.size > 0»
					private static void «action.name»SecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole,
								List<EObject> deleteSecondaryEffects) {
						for (EObject deletedElement : deleteSecondaryEffects) {
								«FOR deleteEffect : action.deleteEffects»
									«IF count === 0»
										if (deletedElement.eClass().equals(«deleteEffect.languageElement»)) {
											«FOR m : deleteEffect.mappings»
												«m.mapping»;
											«ENDFOR»
														
											// Call the respective redefined recursive method
											«deleteEffect.methodCall»;
										}
									«ENDIF»
									«IF count > 0»
										else if (deletedElement.eClass().equals(«deleteEffect.languageElement»)) {
											«FOR m : deleteEffect.mappings»
												«m.mapping»;
											«ENDFOR»
												
											// Call the respective redefined recursive method
											«deleteEffect.methodCall»;
											}
									«ENDIF»
									«counter»
								«ENDFOR»
							}
								
					}
				«ENDIF»

			«ENDFOR»
			/**
			 * This is a helper method which retrieves the corresponding container of an
			 * element to create.
			 * @param perspective
			 * @param scene -  the scene of the models
			 * @param currentOwner
			 * @param otherRole
			 * @return the container of the element to create.
			 */
			private static EObject getOwner(COREPerspective perspective, COREScene scene, EObject currentOwner, String otherRole) {
				EObject ownerOther = null;
			
				List<COREModelElementMapping> ownerMappings = COREPerspectiveUtil.INSTANCE.getMappings(currentOwner, scene);
				outerloop: for (COREModelElementMapping mapping : ownerMappings) {
					ownerOther = COREPerspectiveUtil.INSTANCE.getOtherElement(mapping, currentOwner);
					CORELanguageElementMapping mappingType = COREPerspectiveUtil.INSTANCE.getMappingType(perspective, mapping);
					for (MappingEnd mappingEnd : mappingType.getMappingEnds()) {
						if (mappingEnd.getRoleName().equals(otherRole)) {
							ownerOther = COREPerspectiveUtil.INSTANCE.getOtherElement(mapping, currentOwner);
							break outerloop;
						}
					}
				}
			
				return ownerOther;
			}
		}
		

		'''
	}
}