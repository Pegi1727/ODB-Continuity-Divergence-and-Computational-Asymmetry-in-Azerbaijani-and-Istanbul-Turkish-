# Appendices

## Appendix A: Data Schema and Coding Framework

This appendix presents the field-level schema used to code the 207-item Swadesh dataset for Azerbaijani and Istanbul Turkish.

| Field | Description |
|---|---|
| Concept number | Integer identifier for each Swadesh item |
| Concept gloss | English semantic gloss |
| Proto Turkic reference form | Reconstructed historical form |
| Azerbaijani lexical form | Observed Azerbaijani reflex |
| Turkish lexical form | Observed Istanbul Turkish reflex |
| Cognate classification | IDENT / COG-PHON / REP / LOAN / SEM etc. |
| Phonological correspondence label | Sound-change annotation |
| Semantic change annotation | Semantic drift label |
| Analytical notes | Free-text coder notes |
| Validation status | DRAFT / CHECK |

## Appendix B: Descriptive Overview of the Dataset

This appendix summarizes the overall structure and completeness of the primary dataset.

| Variable | Value |
|---|---|
| Total lexical items | 207 |
| Total variables | 10 |
| Cognate-type categories | 8 |
| Semantic-change categories | 15 |
| Validation-status categories | 2 |
| Primary data file | swadesh_207_azerbaijani_turkish_coding_draft.csv |
| Missing values | none observed |
| Notes | No nulls observed in Notes column |

## Appendix C: Cognate-Type Distribution

This appendix reports the full distribution of cognate classifications across the 207 lexical items.

| Cognate type | Count | Percentage |
|---|---|---|
| COG-PHON | 129 | 62.32 |
| IDENT | 40 | 19.32 |
| REP | 22 | 10.63 |
| SEM/REP | 5 | 2.42 |
| SEM | 4 | 1.93 |
| LOAN | 3 | 1.45 |
| IDENT/COG | 3 | 1.45 |
| REP/LOAN | 1 | 0.48 |
| Total | 207 | 100 |

## Appendix D: Phonological Correspondence Counts

This appendix lists the observed sound correspondences and their frequencies in cognate pairs.

| Phonological shift | Count |
|---|---|
| q/k correspondence | 15 |
| mək/mek alternation | 10 |
| t/d correspondence | 9 |
| ə/e vowel alternation | 8 |
| q/k infinitive correspondence | 8 |
| initial y-loss in Azerbaijani | 6 |
| t/d historical voicing | 4 |
| k/g voicing | 4 |
| q/k with final t/d | 3 |
| final t/d alternation | 3 |
| q/k with final q/k | 3 |

## Appendix E: Semantic Change Distribution

This appendix reports the distribution of semantic-change annotations.

| Semantic change | Count | Percentage |
|---|---|---|
| none | 180 | 86.96 |
| lexical replacement | 15 | 7.25 |
| semantic redistribution | 4 | 1.93 |
| semantic specialization | 2 | 0.97 |
| deictic-location expansion | 2 | 0.97 |
| other minor categories | 4 | 1.92 |
| Total | 207 | 100 |

## Appendix F: Sample Coded Swadesh Items

This appendix shows a sample of fully coded lexical entries from the primary dataset.

| Concept No. | Concept | Proto Turkic | Azerbaijani | Turkish | Cognate Type | Phonological Shift | Semantic Change |
|---|---|---|---|---|---|---|---|
| 1 | I | *ben | mən | ben | COG PHON | b → m | None |
| 2 | you | *sen | sən | sen | COG PHON | vowel ə/e | None |
| 3 | we | *biz | biz | biz | IDENT | none | None |
| 4 | water | *su | su | su | IDENT | none | None |
| 5 | fire | *ot | od | ot | COG PHON | t/d | None |
| 6 | tooth | *tiš | diş | diş | IDENT | none | None |
| 7 | tree | *ağaç | ağac | ağaç | COG PHON | ç/c | None |
| 8 | sun | *kün | gün | gün | COG PHON | k/g | None |

## Appendix G: Validation Status of Coded Entries

This appendix reports the internal validation status (DRAFT / CHECK) of the coded entries.

| Validation status | Count | Percentage |
|---|---|---|
| DRAFT | 185 | 89.37 |
| CHECK | 22 | 10.63 |
| Total | 207 | 100 |

## Appendix H: Summary of Analytical Dimensions

This appendix summarizes the dominant pattern observed in each analytical dimension.

| Analytical dimension | Dominant pattern |
|---|---|
| Lexical relationship | Cognate retention with phonological divergence |
| Lexical identity | substantial secondary layer |
| Replacement rate | relatively limited |
| Semantic change | largely absent |
| Phonological divergence | systematic sound correspondences |
| Coding reliability | high proportion of stable entries |

## Appendix I: LLM Evaluation Results

This appendix reports machine-translation and LLM evaluation results with 95% Wilson confidence intervals.

| Model | Overall Error % | 95% Wilson CI | SEM Error % | SEM CI [L, U] | p-value (vs. GS) |
|---|---|---|---|---|---|
| GPT-4o | 52.1% | [45.2%, 59.0%] | 68.4% | [58.1%, 78.7%] | p < 0.01 |
| Gemini 1.5 | 48.7% | [41.8%, 55.6%] | 61.2% | [50.9%, 71.5%] | p < 0.05 |
| Llama-3 | 58.2% | [51.3%, 65.1%] | 74.1% | [63.8%, 84.4%] | p < 0.001 |
| Google Trans. | 69.3% | [62.4%, 76.2%] | 82.5% | [74.2%, 89.8%] | p < 0.001 |
