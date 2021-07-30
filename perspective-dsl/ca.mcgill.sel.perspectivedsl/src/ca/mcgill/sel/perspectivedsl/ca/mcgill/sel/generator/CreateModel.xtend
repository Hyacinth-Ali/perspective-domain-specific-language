package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective

class CreateModel {
	
	var static count = 0;

    private def static void resetCounter() {
       count = 0;
    }

   private def static void counter() {
       count++;
   }
	
	def static compileCreateModel(Perspective perspective) {
		
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase»;
		
		import java.lang.reflect.InvocationTargetException;
		import java.util.ArrayList;
		import java.util.HashMap;
		import java.util.List;
		import java.util.Map;
		import java.io.IOException;
		import java.lang.Class;
		
		import org.eclipse.emf.common.util.BasicEList;
		import org.eclipse.emf.common.util.EList;
		import org.eclipse.emf.ecore.EObject;
		import org.eclipse.emf.ecore.util.EcoreUtil;
		
		import ca.mcgill.sel.core.*;
		import ca.mcgill.sel.ram.ui.perspective.*;
		import ca.mcgill.sel.core.controller.ModelUtil;
		import ca.mcgill.sel.core.language.registry.CORELanguageRegistry;
		import ca.mcgill.sel.core.perspective.ActionType;
		import ca.mcgill.sel.core.perspective.COREPerspectiveUtil;
		import ca.mcgill.sel.core.perspective.TemplateType;
		import ca.mcgill.sel.ram.ui.perspective.QueryAction;
		
		«FOR language : perspective.languages»
			import «language.rootPackage».*;
		«ENDFOR»

		
		/**
		 * This class handles the creation, as well as, the mapping of root model
		 * elements. This class needs not to be used with TouchCORE.
		 * 
		 * @author hyacinthali
		 *
		 * @generated
		 */
		public class CreateModel {
		
			/**
			 * Map of existing models, each with their corresponding role names.
			 */
			private static Map<String, List<EObject>> existingModels;
		
			/**
			 * Singleton pattern - initialize only a single create model.
			 */
			public static CreateModel INSTANCE = new CreateModel();
		
			private static Map<CORELanguage, ModelUtil> modelUtils;
		
			private CreateModel() {
				modelUtils = new HashMap<CORELanguage, ModelUtil>();
			}
			
			public static CreateModel getInstance() {
				return INSTANCE;
			}
			
			public void initializeExistingModel() {
				existingModels = new HashMap<String, List<EObject>>();	
			}
		
			/**
			 * This method creates creates a new model using the language that plays the role "role" in the perspective.
			 * Finally, calls the recursive method "createOtherExternalModels" to create
			 * the corresponding model(s), if any, and then establish the mapping
			 * between models.
			 * 
			 * @param perspective
			 * @param scene
			 * @param role - role name of the language model
			 * @param name - name of the model
			 * @param isFacadeCall - yes if the call is from facade action.
			 * @return
			 */
			public EObject createNewModel(COREPerspective perspective, COREScene scene, String role, String name, boolean isFacadeCall) {
		
				// initialize existing model maps
				existingModels = new HashMap<String, List<EObject>>();
				
				// create new model
				EObject externalModel = createModel(perspective, scene, role, name);
		
				// Check if there are any mandatory CORELanguageElementMappings that
				// dictate
				// that other models must be created
				if (!isFacadeCall) {
					createOtherModels(perspective, scene, role, externalModel, name);
				}
				// clear existing role names
		//		existingModels.clear();
		
				return externalModel;
		
			}
		
			/**
			 * This method recursively creates other model(s) and then establishes the
			 * mapping between the models, respectively.
			 * 
			 * @param perspective
			 * @param scene
			 * @param currentRoleName
			 * @param extModel
			 * @param name
			 * @throws PerspectiveException
			 */
			private static void createOtherModels(COREPerspective perspective, COREScene scene, String currentRoleName,
					EObject extModel, String name) {
		
				addNewElement(extModel, currentRoleName);
		
				List<CORELanguageElementMapping> mappingTypes = COREPerspectiveUtil.INSTANCE.getMappingTypes(perspective,
						extModel.eClass(), currentRoleName);
				for (CORELanguageElementMapping mappingType : mappingTypes) {
					List<COREModelElementMapping> mappings = COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene,
							extModel);
					if (COREPerspectiveUtil.INSTANCE.mappingsContainsElement(mappings, extModel)) {
						continue;
					}
					
					MappingEnd currentMappingEnd = COREPerspectiveUtil.INSTANCE.getMappingEnd(mappingType, extModel.eClass(), currentRoleName);
					MappingEnd otherMappingEnd = COREPerspectiveUtil.INSTANCE.getOtherMappingEnds(currentMappingEnd).get(0);
		
					if (otherMappingEnd.isRootMappingEnd()) {
						createOtherRootModels(perspective, mappingType, scene, currentRoleName, extModel, name);
					} else {
						facadeNoneRootOtherElements(perspective, mappingType, scene, currentRoleName, extModel, name);
					}
		
				}
			}
		
			private static void facadeNoneRootOtherElements(COREPerspective perspective, CORELanguageElementMapping mappingType,
					COREScene scene, String currentRoleName, EObject currentModel, String name) {
		
				EObject otherLE = COREPerspectiveUtil.INSTANCE
						.getOtherLanguageElements(mappingType, currentModel.eClass(), currentRoleName).get(0);
				String otherRoleName = COREPerspectiveUtil.INSTANCE.getOtherRoleName(mappingType, currentRoleName);
				«resetCounter»
				«FOR facade : perspective.rootFacades»
					«IF count === 0»
						if (otherLE.equals(«facade.languageElement»)) {
							// Handle parameter mappings
							«FOR m : facade.mappings»
								«m.mapping»;
							«ENDFOR»
							«facade.methodCall»;
						}
					«ENDIF»
					«IF count > 0»
						else if (otherLE.equals(«facade.languageElement»)) {
							// Handle parameter mappings
							«FOR m : facade.mappings»
								«m.mapping»;
							«ENDFOR»
							«facade.methodCall»;
						}
					«ENDIF»
					«counter»
				«ENDFOR»
			
			}
		
			public static void createOtherRootModels(COREPerspective perspective, CORELanguageElementMapping mappingType,
					COREScene scene, String currentRoleName, EObject extModel, String name) {
		
				String otherRoleName = COREPerspectiveUtil.INSTANCE.getOtherRoleName(mappingType, currentRoleName);
		
				// the metaclass of the element to be created.
				EObject otherLE = COREPerspectiveUtil.INSTANCE
						.getOtherLanguageElements(mappingType, extModel.eClass(), currentRoleName).get(0);
		
				ActionType actionType = TemplateType.INSTANCE.getCreateType(mappingType, currentRoleName);
		
				switch (actionType) {
		
				// C1/C9
				case CAN_CREATE:
				case CAN_CREATE_OR_USE_NON_MAPPED:
					canCreateOrUseNonMappedModel(perspective, mappingType, scene, extModel, otherRoleName, otherLE, name);
					break;
		
				// C2/C10
				case CREATE:
				case CREATE_OR_USE_NON_MAPPED:
					createOrUseNonMappedModel(perspective, mappingType, scene, extModel, otherRoleName, otherLE, name);
					break;
		
				// C3/C11
				case CAN_CREATE_MANY:
				case CAN_CREATE_OR_USE_NON_MAPPED_MANY:
					canCreateOrUseNonMappedManyModels(perspective, mappingType, scene, extModel, otherRoleName, otherLE, name);
					break;
		
				// C4/C12
				case CREATE_AT_LEAST_ONE:
				case CREATE_OR_USE_NON_MAPPED_AT_LEAST_ONE:
					createOrUseNonMappedAtLeastOneModel(perspective, mappingType, scene, extModel, otherRoleName, otherLE,
							name);
					break;
		
				// C5
				case CAN_CREATE_OR_USE:
					canCreateOrUseModel(perspective, mappingType, scene, extModel, otherRoleName, otherLE, name);
					break;
		
				// C6
				case CREATE_OR_USE:
					createOrUseModel(perspective, mappingType, scene, extModel, otherRoleName, otherLE, name);
					break;
		
				// C7
				case CAN_CREATE_OR_USE_MANY:
					canCreateOrUseManyModels(perspective, mappingType, scene, extModel, otherRoleName, otherLE, name);
					break;
		
				// C8
				case CREATE_OR_USE_AT_LEAST_ONE:
					createOrUseAtLeastOneModel(perspective, mappingType, scene, extModel, otherRoleName, otherLE, name);
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
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void canCreateOrUseModel(COREPerspective perspective, CORELanguageElementMapping mappingType,
					COREScene scene, EObject currentElement, String otherRoleName, EObject otherLE, String name) {
		
				EObject otherModel = null;
				boolean otherExist = true;
				// Ask the user whether to create other model element and then establish
				// the MEM
				boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
				if (isCreateMapping) {
					otherModel = findExistingNewModel(otherRoleName);
					if (otherModel == null) {
						otherExist = false;
						otherModel = createModel(perspective, scene, otherRoleName, name);
					}
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
							false);
					// save the recent changes
					// BasePerspectiveController.saveModel(scene);
					if (!otherExist) {
						createOtherModels(perspective, scene, otherRoleName, otherModel, name);
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
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void createOrUseModel(COREPerspective perspective, CORELanguageElementMapping mappingType,
					COREScene scene, EObject currentElement, String otherRoleName, EObject otherLE, String name) {
		
				EObject otherModel = null;
				boolean otherExist = true;
				otherModel = findExistingNewModel(otherRoleName);
				if (otherModel == null) {
					otherExist = false;
					otherModel = createModel(perspective, scene, otherRoleName, name);
				}
				COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
						false);
				// BasePerspectiveController.saveModel(scene);
				if (!otherExist) {
					createOtherModels(perspective, scene, otherRoleName, otherModel, name);
				}
		
			}
		
			/**
			 * (C3/C7): This method can create or use an existing elements to establish
			 * model element mappings between the "element" parameter and each of the
			 * new element or existing elements. Similarly, the usser decides if the
			 * method should create the mappings.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void canCreateOrUseManyModels(COREPerspective perspective,
					CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement, String otherRoleName,
					EObject otherLE, String name) {
		
				EObject otherModel = null;
				// Ask user how many mappings to create
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappings();
				List<EObject> otherElements = findExistingNewModels(otherRoleName);
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						otherModel = existingElement;
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement,
								otherModel, false);
						// BasePerspectiveController.saveModel(scene);
						numberOfMappings--;
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherModel = createModel(perspective, scene, otherRoleName, name);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
							false);
					// BasePerspectiveController.saveModel(scene);
					createOtherModels(perspective, scene, otherRoleName, otherModel, name);
				}
			}
		
			/**
			 * (C4/C8): This method proactively creates or uses an existing element, at
			 * least one element, to establishes model element mapping between the
			 * "element" parameter and the new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void createOrUseAtLeastOneModel(COREPerspective perspective,
					CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement, String otherRoleName,
					EObject otherLE, String name) {
		
				EObject otherModel = null;
				// Ask user how many mappings to create
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappingsAtLeastOne();
				List<EObject> otherElements = findExistingNewModels(otherRoleName);
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						otherModel = existingElement;
						COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement,
								otherModel, false);
						// BasePerspectiveController.saveModel(scene);
						numberOfMappings--;
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherModel = createModel(perspective, scene, otherRoleName, name);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
							false);
					// BasePerspectiveController.saveModel(scene);
					createOtherModels(perspective, scene, otherRoleName, otherModel, name);
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
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void canCreateOrUseNonMappedModel(COREPerspective perspective,
					CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement, String otherRoleName,
					EObject otherLE, String name) {
		
				EObject otherModel = null;
				boolean otherExist = true;
				boolean isCreateMapping = QueryAction.INSTANCE.isCreateMapping();
				if (isCreateMapping) {
					otherModel = findExistingNewModel(otherRoleName);
					// creates new element if other element does not exist or it is
					// already mapped.
					if (otherModel == null
							|| COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherModel).size() != 0) {
						otherExist = false;
						otherModel = createModel(perspective, scene, otherRoleName, name);
					}
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
							false);
					// BasePerspectiveController.saveModel(scene);
					if (!otherExist) {
						createOtherModels(perspective, scene, otherRoleName, otherModel,
								name);
					}
		
				}
			}
		
			/**
			 * (C10): This method proactively creates or uses non-mapped existing
			 * element to establishes model element mapping between the "element"
			 * parameter and the new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void createOrUseNonMappedModel(COREPerspective perspective,
					CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement, String otherRoleName,
					EObject otherLE, String name) {
		
				EObject otherModel = null;
				boolean otherExist = true;
				otherModel = findExistingNewModel(otherRoleName);
		
				// create other element if the corresponding element is null
				// or mapped.
				if (otherModel == null
						|| COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, otherModel).size() > 0) {
					otherExist = false;
					otherModel = createModel(perspective, scene, otherRoleName, name);
				}
				COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
						false);
				// BasePerspectiveController.saveModel(scene);
				// stop the recursion if other element exists.
				if (!otherExist) {
					createOtherModels(perspective, scene, otherRoleName, otherModel, name);
				}
			}
		
			/**
			 * (C11): This method can create many elements or use non-mapped existing
			 * elements to establish model element mappings between the "element"
			 * parameter and each of the new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void canCreateOrUseNonMappedManyModels(COREPerspective perspective,
					CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement, String otherRoleName,
					EObject otherLE, String name) {
		
				EObject otherModel = null;
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappings();
				List<EObject> otherElements = findExistingNewModels(otherRoleName);
				// create mapping for each corresponding element which is not mapped
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						if (COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, existingElement).size() == 0) {
							otherModel = existingElement;
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement,
									otherModel, false);
							// BasePerspectiveController.saveModel(scene);
							numberOfMappings--;
						}
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherModel = createModel(perspective, scene, otherRoleName, name);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
							false);
					// BasePerspectiveController.saveModel(scene);
					createOtherModels(perspective, scene, otherRoleName, otherModel, name);
				}
			}
		
			/**
			 * (C12): This method proactively creates many elements or uses non-mapped
			 * existing elements to establish model element mappings between the
			 * "element" parameter and each of the new element or the existing element.
			 * 
			 * @author Hyacinth Ali
			 * 
			 * @param perspective
			 * @param mappingType
			 * @param scene
			 * @param currentElement
			 * @param otherRoleName
			 * @param otherLE
			 * @param name
			 * @param currentOwner
			 */
			private static void createOrUseNonMappedAtLeastOneModel(COREPerspective perspective,
					CORELanguageElementMapping mappingType, COREScene scene, EObject currentElement, String otherRoleName,
					EObject otherLE, String name) {
		
				EObject otherModel = null;
				// Ask user how many mappings to create (at least one)
				int numberOfMappings = QueryAction.INSTANCE.askNumberOfMappingsAtLeastOne();
				List<EObject> otherElements = findExistingNewModels(otherRoleName);
				// create mapping for each corresponding element which is not mapped
				for (EObject existingElement : otherElements) {
					if (numberOfMappings <= 0) {
						break;
					} else {
						if (COREPerspectiveUtil.INSTANCE.getMappings(mappingType, scene, existingElement).size() == 0) {
							otherModel = existingElement;
							COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement,
									otherModel, false);
							// BasePerspectiveController.saveModel(scene);
							numberOfMappings--;
						}
					}
				}
				for (int count = 0; count < numberOfMappings; count++) {
					otherModel = createModel(perspective, scene, otherRoleName, name);
					COREPerspectiveUtil.INSTANCE.createMapping(perspective, scene, mappingType, currentElement, otherModel,
							false);
					// BasePerspectiveController.saveModel(scene);
					createOtherModels(perspective, scene, otherRoleName, otherModel, name);
				}
			}
		
			/**
			 * This method creates a new model based on the given language l, as well as
			 * a new COREExternalArtefact and initializes it to the given name.
			 * 
			 * @param perspective
			 * @param scene
			 * @param role
			 * @param name
			 * @return
			 */
			private static EObject createModel(COREPerspective perspective, COREScene scene, String role, String name) {
				EObject externalModel;
		
				CORELanguage l = perspective.getLanguages().get(role);
				
				// create the model using the language's model util
				ModelUtil mu = CORELanguageRegistry.getRegistry().getModelUtil(l);
				externalModel = mu.createNewEmptyModel(name);
		
				// create a COREExternalArtefact that refers to the new model 
				COREExternalArtefact externalArtefact = CoreFactory.eINSTANCE.createCOREExternalArtefact();
				externalArtefact.setLanguageName(l.getName());
				externalArtefact.setRootModelElement(externalModel);
				externalArtefact.setName(name);
		
				EList<COREArtefact> artefacts = scene.getArtefacts().get(role);
				if (artefacts == null) {
					artefacts = new BasicEList<COREArtefact>();
				}
				artefacts.add(externalArtefact);
				scene.getArtefacts().put(role, artefacts);
				externalArtefact.setScene(scene);
				
				try {
					COREConcern concern = (COREConcern) EcoreUtil.getRootContainer(scene);
					COREPerspectiveUtil.INSTANCE.saveModel(concern, role, externalArtefact);
				} catch (IOException e) {
				}
				
				return externalModel;
			}
			
			public void setModelUtils(COREExternalLanguage language) {
		
				String modelUtilName = language.getModelUtilClassName();
				if (modelUtilName != null && !modelUtilName.isEmpty()) {
					Class<?> modelUtil = null;
					try {
						modelUtil = Class.forName(modelUtilName);
					} catch (ClassNotFoundException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					try {
						modelUtils.put(language, (ModelUtil) modelUtil.getDeclaredConstructor().newInstance());
					} catch (InstantiationException | IllegalAccessException | IllegalArgumentException
							| InvocationTargetException | NoSuchMethodException | SecurityException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			}
		
			/**
			 * Checks if a model with the role "role" already exist.
			 * 
			 * @param role - the role of the model
			 * @return the model
			 */
			private static EObject findExistingNewModel(String role) {
				EObject existingModel = null;
				for (Map.Entry<String, List<EObject>> entry : existingModels.entrySet()) {
					String key = entry.getKey();
					if (key.equals(role)) {
						existingModel = entry.getValue().get(0);
						break;
					}
				}
				return existingModel;
			}
			
			/**
			 * Returns existing models with the role "role".
			 * 
			 * @param role - the role of the models
			 * @return the model
			 */
			private static List<EObject> findExistingNewModels(String role) {
				List<EObject> models = new ArrayList<>();
				for (Map.Entry<String, List<EObject>> entry : existingModels.entrySet()) {
					String key = entry.getKey();
					if (key.equals(role)) {
						models.addAll(entry.getValue());
						break;
					}
				}
				return models;
			}
			
			private static void addNewElement(EObject newElement, String role) {
				List<EObject> elements = new ArrayList<>();
				if (existingModels.keySet().contains(role)) {
					elements = existingModels.get(role);
				}
				elements.add(newElement);
				existingModels.put(role, elements);
			}
			
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