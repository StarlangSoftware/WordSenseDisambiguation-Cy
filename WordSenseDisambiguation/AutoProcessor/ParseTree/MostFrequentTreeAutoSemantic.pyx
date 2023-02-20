from AnnotatedSentence.ViewLayerType import ViewLayerType
from AnnotatedTree.ParseTreeDrawable cimport ParseTreeDrawable
from AnnotatedTree.Processor.Condition.IsTurkishLeafNode cimport IsTurkishLeafNode
from AnnotatedTree.Processor.NodeDrawableCollector cimport NodeDrawableCollector
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from WordNet.SynSet cimport SynSet
from WordNet.WordNet cimport WordNet
from WordSenseDisambiguation.AutoProcessor.ParseTree.TreeAutoSemantic cimport TreeAutoSemantic

cdef class MostFrequentTreeAutoSemantic(TreeAutoSemantic):

    cpdef WordNet __turkish_wordnet
    cpdef FsmMorphologicalAnalyzer __fsm

    def __init__(self, turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer):
        self.__fsm = fsm
        self.__turkish_wordnet = turkishWordNet

    cpdef SynSet mostFrequent(self, list synSets, str root):
        cdef SynSet synSet, best
        cdef int min_sense, i
        if len(synSets) == 1:
            return synSets[0]
        min_sense = 50
        best = None
        for syn_set in synSets:
            for i in range(syn_set.getSynonym().literalSize()):
                if syn_set.getSynonym().getLiteral(i).getName().lower().startswith(root) or syn_set.getSynonym().getLiteral(i).getName().lower().endswith(" " + root):
                    if syn_set.getSynonym().getLiteral(i).getSense() < min_sense:
                        min_sense = syn_set.getSynonym().getLiteral(i).getSense()
                        best = syn_set
        return best

    cpdef bint autoLabelSingleSemantics(self, ParseTreeDrawable parseTree):
        cdef NodeDrawableCollector node_drawable_collector
        cdef int i
        cdef list leaf_list
        cdef list syn_sets
        cdef SynSet best
        node_drawable_collector = NodeDrawableCollector(parseTree.getRoot(), IsTurkishLeafNode())
        leaf_list = node_drawable_collector.collect()
        for i in range(len(leaf_list)):
            syn_sets = self.getCandidateSynSets(self.__turkish_wordnet, self.__fsm, leaf_list, i)
            if len(syn_sets) > 0:
                best = self.mostFrequent(syn_sets, leaf_list[i].getLayerInfo().getMorphologicalParseAt(0).getWord().getName())
                if best is not None:
                    leaf_list[i].getLayerInfo().setLayerData(ViewLayerType.SEMANTICS, best.getId())
        return True
