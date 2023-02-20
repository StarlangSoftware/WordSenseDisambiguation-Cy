from AnnotatedTree.LayerInfo cimport LayerInfo

cdef class TreeAutoSemantic:

    cpdef bint autoLabelSingleSemantics(self, ParseTreeDrawable parseTree):
        pass

    cpdef list getCandidateSynSets(self, WordNet wordNet, FsmMorphologicalAnalyzer fsm, list leafList, int index):
        cdef LayerInfo two_previous, previous, two_next, next, current
        cdef list syn_sets
        two_previous = None
        previous = None
        two_next = None
        next = None
        current = leafList[index].getLayerInfo()
        if index > 1:
            two_previous = leafList[index - 2].getLayerInfo()
        if index > 0:
            previous = leafList[index - 1].getLayerInfo()
        if index != len(leafList) - 1:
            next = leafList[index + 1].getLayerInfo()
        if index < len(leafList) - 2:
            two_next = leafList[index + 2].getLayerInfo()
        syn_sets = wordNet.constructSynSets(current.getMorphologicalParseAt(0).getWord().getName(),
                    current.getMorphologicalParseAt(0), current.getMetamorphicParseAt(0), fsm)
        if two_previous is not None and two_previous.getMorphologicalParseAt(0) is not None and previous.getMorphologicalParseAt(0) is not None:
            syn_sets.extend(wordNet.constructIdiomSynSets(fsm, two_previous.getMorphologicalParseAt(0), two_previous.getMetamorphicParseAt(0),
                                                         previous.getMorphologicalParseAt(0), previous.getMetamorphicParseAt(0),
                                                         current.getMorphologicalParseAt(0), current.getMetamorphicParseAt(0)))
        if previous is not None and previous.getMorphologicalParseAt(0) is not None and next is not None and next.getMorphologicalParseAt(0) is not None:
            syn_sets.extend(wordNet.constructIdiomSynSets(fsm, previous.getMorphologicalParseAt(0), previous.getMetamorphicParseAt(0),
                                                         current.getMorphologicalParseAt(0), current.getMetamorphicParseAt(0),
                                                         next.getMorphologicalParseAt(0), next.getMetamorphicParseAt(0)))
        if next is not None and next.getMorphologicalParseAt(0) is not None and two_next is not None and two_next.getMorphologicalParseAt(0) is not None:
            syn_sets.extend(wordNet.constructIdiomSynSets(fsm, current.getMorphologicalParseAt(0), current.getMetamorphicParseAt(0),
                                                         next.getMorphologicalParseAt(0), next.getMetamorphicParseAt(0),
                                                         two_next.getMorphologicalParseAt(0), two_next.getMetamorphicParseAt(0)))
        if previous is not None and previous.getMorphologicalParseAt(0) is not None:
            syn_sets.extend(wordNet.constructIdiomSynSets(fsm, previous.getMorphologicalParseAt(0), previous.getMetamorphicParseAt(0),
                                                         current.getMorphologicalParseAt(0), current.getMetamorphicParseAt(0)))
        if next is not None and next.getMorphologicalParseAt(0) is not None:
            syn_sets.extend(wordNet.constructIdiomSynSets(fsm, current.getMorphologicalParseAt(0), current.getMetamorphicParseAt(0),
                                                         next.getMorphologicalParseAt(0), next.getMetamorphicParseAt(0)))
        return syn_sets

    cpdef autoSemantic(self, ParseTreeDrawable parseTree):
        self.autoLabelSingleSemantics(parseTree)
