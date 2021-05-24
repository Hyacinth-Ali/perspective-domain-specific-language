package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective

class HandleSecondaryEffect {
	
		var static count = 0;

    private def static void resetCounter() {
       count = 0;
    }

   private def static void counter() {
       count++;
   }
	
	def static compileHandleSsecondaryEffects(Perspective perspective) {
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase»;
		
		import java.util.Collection;
		import java.util.List;
		import java.util.Map;
		import org.eclipse.emf.ecore.EObject;
		
		import ca.mcgill.sel.core.*;
		
		«FOR l : perspective.languages»
			import «l.rootPackage».*;
		«ENDFOR»
		
		public class HandleSecondaryEffect {
			
			public static HandleSecondaryEffect INSTANCE = new HandleSecondaryEffect();
				
			private HandleSecondaryEffect() {
					
			}
			
			«resetCounter»
			«IF perspective.createSecondaryEffect !== null»
				public void createSecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole, Map<EObject, Collection<EObject>> after, EObject owner, String name) {
					for (Map.Entry<EObject, Collection<EObject>> e : after.entrySet()) {
						Collection<EObject> newElements = e.getValue();
						for (EObject newElement : newElements) {
							«FOR facadeCall : perspective.createSecondaryEffect.facadeCalls»
								«IF count === 0»
									if (newElement.eClass().equals(«facadeCall.metaclassObject»)) {
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
													
										// Call the respective redefined recursive method
										«facadeCall.methodCall»;
									}
								«ENDIF»
								«IF count > 0»
									else if (newElement.eClass().equals(«facadeCall.metaclassObject»)) {
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
											
										// Call the respective redefined recursive method
										«facadeCall.methodCall»;
										}
								«ENDIF»
								«counter»
							«ENDFOR»
						}
					}
				}
			«ENDIF»
			«resetCounter»
			«IF perspective.deleteSecondaryEffect !== null»
				public void deleteSecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole,
							List<EObject> deleteSecondaryEffects) {
					for (EObject deletedElement : deleteSecondaryEffects) {
							«FOR facadeCall : perspective.deleteSecondaryEffect.facadeCalls»
								«IF count === 0»
									if (deletedElement.eClass().equals(«facadeCall.metaclassObject»)) {
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
													
										// Call the respective redefined recursive method
										«facadeCall.methodCall»;
									}
								«ENDIF»
								«IF count > 0»
									else if (deletedElement.eClass().equals(«facadeCall.metaclassObject»)) {
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
											
										// Call the respective redefined recursive method
										«facadeCall.methodCall»;
										}
								«ENDIF»
								«counter»
							«ENDFOR»
						}
							
				}
			«ENDIF»
			}
			
		'''
		
	}
	
}