package ca.mcgill.sel.core.language;

import java.io.IOException;
import org.eclipse.emf.ecore.EObject;

import ca.mcgill.sel.commons.emf.util.AdapterFactoryRegistry;
import ca.mcgill.sel.commons.emf.util.ResourceManager;
import ca.mcgill.sel.core.util.CoreResourceFactoryImpl;
import ca.mcgill.sel.core.provider.CoreItemProviderAdapterFactory;
import ca.mcgill.sel.ram.ui.utils.ResourceUtils;
import ca.mcgill.sel.core.util.COREModelUtil;

import ca.mcgill.sel.core.*;
import ca.mcgill.sel.core.util.*;

import ca.mcgill.sel.classdiagram.*;

public class CDM {

    public static void main (String[] args) {

        // Initialize ResourceManager
        ResourceManager.initialize();

        // Initialize CORE packages.
        CorePackage.eINSTANCE.eClass();

        // Register resource factories
        ResourceManager.registerExtensionFactory("core", new CoreResourceFactoryImpl());

        // Initialize adapter factories
        AdapterFactoryRegistry.INSTANCE.addAdapterFactory(CoreItemProviderAdapterFactory.class);

        ResourceUtils.loadLibraries();

        createLanguage();
    }

    /**
     * This method registers existing language (with its details) in TouchCORE.
     *
     * @author Hyacinth Ali
     * @return the class diagram {@link COREExternalLanguage}
     *
     * @generated
     */
    public static COREExternalLanguage createLanguage() {

    // create a language concern
    COREConcern langConcern = COREModelUtil.createConcern("CDM");

    COREExternalLanguage language = CoreFactory.eINSTANCE.createCOREExternalLanguage();
    language.setName("CDM_Gen");
    language.setNsURI("http://cs.mcgill.ca/sel/cdm/1.0");
    language.setResourceFactory("ca.mcgill.sel.classdiagram.util.CdmResourceFactoryImpl");
    language.setAdapterFactory("ca.mcgill.sel.classdiagram.provider.CdmItemProviderAdapterFactory");
    language.setWeaverClassName("ca.mcgill.sel.ram.weaver.RAMWeaver");
    language.setFileExtension("cdm");
    language.setModelUtilClassName("ca.mcgill.sel.classdiagram.util.CdmModelUtil");

    createLanguageElements(language);

    createLanguageActions(language);

    langConcern.getArtefacts().add(language);

    String language1FileName = "/Users/hyacinthali/git/touchram/ca.mcgill.sel.ram/resources/resources/models/testlanguages/"
            + "CDM";

     try {
         ResourceManager.saveModel(langConcern, language1FileName.concat("." + "core"));
     } catch (IOException e) {
         // Shouldn't happen.
         e.printStackTrace();
     }

     return language;
    }

    private static void createLanguageElements(COREExternalLanguage language) {

        // create classdiagram core language element
        CORELanguageElement Class = createCORELanguageElement(language, CdmPackage.eINSTANCE.getClass_());


        // create classdiagram core language element
        CORELanguageElement Attribute = createCORELanguageElement(language, CdmPackage.eINSTANCE.getAttribute());



    }

    /**
    * This method creates an instance of {@link CORELanguageElement} for a given language {@link COREExternalLanguage}
    * and its existing language element.
    * @param language - the language in question.
    * @param languageElement - the existing language element.
    * @return the new instance of {@link CORELanguageElement}
    *
    * @generated
    */
    private static CORELanguageElement createCORELanguageElement(COREExternalLanguage language,
            EObject languageElement) {

        // create core language element
        CORELanguageElement coreLanguageElement = CoreFactory.eINSTANCE.createCORELanguageElement();
        coreLanguageElement.setLanguageElement(languageElement);
        language.getLanguageElements().add(coreLanguageElement);

        return coreLanguageElement;
    }

    /**
     * This method creates an instance of {@link CORELanguageElement}, nested element, for a given language {@link COREExternalLanguage}
    * and its existing language element.
    * @param language - the language in question.
    * @param languageElement - the existing language element.
    * @param container - the {@link CORELanguageElement} container of the new element
    * @param name - name of the language element attribute
    *
    * @generated
    */
    private static void createNestedCORELanguageElement(COREExternalLanguage language, EObject languageElement,
            CORELanguageElement container, String name) {

        // create core language element
        CORELanguageElement coreLanguageElement = CoreFactory.eINSTANCE.createCORELanguageElement();
        coreLanguageElement.setName(name);
        coreLanguageElement.setLanguageElement(CdmPackage.eINSTANCE.getNamedElement_Name());

        container.getNestedElements().add(coreLanguageElement);
        coreLanguageElement.setOwner(container);
    }

    /**
    * This method creates language actions, which can be manipulated by the perspectives
    * which reuse the language.
    *
    * @author Hyacinth Ali
    * @param language - the language
    *
    * @generated
    */
    private static void createLanguageActions(COREExternalLanguage language) {

        CORELanguageAction lAction1 = CoreFactory.eINSTANCE.createCORELanguageAction();
        lAction1.setName("CDM.Class.createClass(ClassDiagram owner, float x, float y)");
        language.getActions().add(lAction1);

        CORELanguageAction lAction2 = CoreFactory.eINSTANCE.createCORELanguageAction();
        lAction2.setName("CDM.Attribute.createAttribute(Class owner, float x, float y)");
        language.getActions().add(lAction2);

    }
}
