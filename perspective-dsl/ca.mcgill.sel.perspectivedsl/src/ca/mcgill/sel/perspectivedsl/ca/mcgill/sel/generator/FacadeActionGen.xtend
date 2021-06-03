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
		
		import java.util.List;
		import org.eclipse.emf.ecore.EObject;
		
		import ca.mcgill.sel.core.*;
		import ca.mcgill.sel.core.perspective.COREPerspectiveUtil;
		
		import «language.rootPackage».*;
		«FOR p : language.otherRootPackages»
			import «p.otherRootPackage».*;
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