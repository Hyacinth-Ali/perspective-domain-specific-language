package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.CreateFacadeAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.DeleteFacadeAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Language
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.CreateAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.DeleteAction

class FacadeActionGen {
	
	var static count = 0;

    private def static void resetCounter() {
       count = 0;
    }

   private def static void counter() {
       count++;
   }
	
	def static compileFacadeActions(Perspective perspective, Language language) {
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase»;
		
		import java.util.ArrayList;
		import java.util.Collection;
		import java.util.HashMap;
		import java.util.List;
		import java.util.Map;
		
		import org.eclipse.emf.ecore.EObject;
		
		import ca.mcgill.sel.core.*;
		import ca.mcgill.sel.core.perspective.COREPerspectiveUtil;
		
		import «language.rootPackage».*;
		import «language.controllerPackage».*;
		«FOR p : language.otherRootPackages»
			import «p.otherRootPackage».*;
		«ENDFOR»
		«FOR p : language.explicitPackages»
			import «p.explicitPackage».*;
		«ENDFOR»
		«FOR l : perspective.languages»
			import «l.controllerPackage».*;
		«ENDFOR»
		
		public class «language.name»FacadeAction {
			«FOR action : language.actions»
				«IF action instanceof CreateAction»
					«var createAction = action as CreateAction»
					«var facadeAction = createAction.createFacadeAction»
					«resetCounter»
					«IF facadeAction.roleName.equals(language.roleName)»
						public static EObject createOtherElementsFor«facadeAction.metaclassName»(COREPerspective perspective, EObject otherLE, String otherRoleName, COREScene scene, 
								«facadeAction.typeParameters») {
							EObject newElement = null;
							«FOR facadeCall : facadeAction.facadeCalls»
								«IF count === 0»
									if (otherLE.equals(«facadeCall.metaclassObject»)) {
										// Handle parameter mappings
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
										newElement = «facadeCall.methodCall»;
									}
								«ENDIF»
								«IF count > 0»
									else if (otherLE.equals(«facadeCall.metaclassObject»)) {
										// Handle parameter mappings
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
										newElement = «facadeCall.methodCall»;
									}
								«ENDIF»
								«counter»
							«ENDFOR»
							
							return newElement;						
						}
					«ENDIF»
					
					public static EObject «action.name»(COREPerspective perspective, COREScene scene, String currentRole, 
						«action.typeParameters») {
							
						EObject newElement = null;
						«IF !action.rootElement»
							List<EObject> createSecondaryEffects = new ArrayList<EObject>();
							«FOR createEffect : action.createEffects»
								createSecondaryEffects.add(«createEffect.languageElement»);
							«ENDFOR»
								
							// record existing elements.
							ModelElementStatus.INSTANCE.setMainExistingElements(owner, «action.metaclassObject»);
							ModelElementStatus.INSTANCE.setOtherExistingElements(owner, createSecondaryEffects);
								
							// primary language action to create a new element
							«action.methodCall»;
							
							// retrieve the new element
							newElement = ModelElementStatus.INSTANCE.getNewElement(owner, «action.metaclassObject»);
								
							// get other new elements for each language element
							Map<EObject, Collection<EObject>> a = ModelElementStatus.INSTANCE.getOtherNewElements(owner, createSecondaryEffects);
							Map<EObject, Collection<EObject>> after = new HashMap<EObject, Collection<EObject>>(a);
	
							«IF action.createEffects.size > 0» 	
								«action.name»SecondaryEffects(perspective, scene, currentRole, after, owner, 
									«action.methodParameter»);
							«ENDIF»
								
						«ENDIF»
						
						return newElement;
						
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
					private static void «action.name»DeleteSecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole,
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

			«var facadeAction = language.deleteFacadeAction»
			«resetCounter»
			«IF facadeAction.roleName.equals(language.roleName)»
			public static void «facadeAction.name»(COREPerspective perspective, COREScene scene, String otherRoleName, EObject «facadeAction.elementName») {
				«FOR methodCall : facadeAction.methodCalls»
					«IF count === 0»
						if («facadeAction.elementName».eClass().equals(«methodCall.metaclassObject»)) {
							«methodCall.methodCall»;
						}
					«ENDIF»
					«IF count > 0»
						else if («facadeAction.elementName».eClass().equals(«methodCall.metaclassObject»)) {
							«methodCall.methodCall»;
						}
					«ENDIF»
					«counter»
				«ENDFOR»						
			}
			«ENDIF»

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