import { describe, it, expect } from '@ohos/hypium';
import {
  DESIGN_HEIGHT,
  DESIGN_WIDTH,
  TEMPLATE_DEFINITIONS,
  createDefaultDraft,
  getTemplateDefinition,
  isValidCustomEpisode
} from '../main/ets/model/CoverModels';

export default function localUnitTest() {
  describe('coverModel', () => {
    it('uses1920DesignCoordinates', 0, () => {
      expect(DESIGN_WIDTH).assertEqual(1920);
      expect(DESIGN_HEIGHT).assertEqual(1080);
    });

    it('containsNineTypedTemplates', 0, () => {
      expect(TEMPLATE_DEFINITIONS.length).assertEqual(9);
      expect(getTemplateDefinition(8).capabilities.requiresPhoto).assertFalse();
      expect(getTemplateDefinition(9).capabilities.supportsPodcastFields).assertTrue();
      expect(getTemplateDefinition(1).capabilities.supportsEpisode).assertFalse();
      expect(getTemplateDefinition(6).capabilities.supportsEpisode).assertTrue();
    });

    it('validatesEpisodeCharacterRules', 0, () => {
      expect(isValidCustomEpisode('字')).assertTrue();
      expect(isValidCustomEpisode('9')).assertTrue();
      expect(isValidCustomEpisode('10')).assertTrue();
      expect(isValidCustomEpisode('特别')).assertFalse();
      expect(isValidCustomEpisode('100')).assertFalse();
    });

    it('buildsLocalDraftDefaults', 0, () => {
      const draft = createDefaultDraft(getTemplateDefinition(3));
      expect(draft.templateId).assertEqual(3);
      expect(draft.versionLabel).assertEqual('会员专享');
      expect(draft.publishDate.length).assertEqual(10);
    });
  });
}
