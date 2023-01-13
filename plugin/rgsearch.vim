if exists('g:fern_mapping_rgsearch_loaded')
  finish
endif
let g:fern_mapping_rgsearch_loaded = 1

call extend(g:fern#mapping#mappings, ['rgsearch'])

