from random import randrange
import random

from AnnotatedSentence.ViewLayerType import ViewLayerType
from AnnotatedTree.ParseTreeDrawable cimport ParseTreeDrawable
from AnnotatedTree.Processor.Condition.IsTurkishLeafNode cimport IsTurkishLeafNode
from AnnotatedTree.Processor.NodeDrawableCollector cimport NodeDrawableCollector
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from WordNet.WordNet cimport WordNet
from WordSenseDisambiguation.AutoProcessor.ParseTree.TreeAutoSemantic cimport TreeAutoSemantic

cdef class RandomTreeAutoSemantic(TreeAutoSemantic):

    cpdef WordNet __turkish_wordnet
    cpdef FsmMorphologicalAnalyzer __fsm

    def __init__(self, turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer):
        self.__fsm = fsm
        self.__turkish_wordnet = turkishWordNet

    cpdef bint autoLabelSingleSemantics(self, ParseTreeDrawable parseTree):
        cdef NodeDrawableCollector nodeDrawableCollector
        cdef int i
        cdef list syn_sets
        random.seed(1)
        node_drawable_collector = NodeDrawableCollector(parseTree.getRoot(), IsTurkishLeafNode())
        leaf_list = node_drawable_collector.collect()
        for i in range(len(leaf_list)):
            syn_sets = self.getCandidateSynSets(self.__turkish_wordnet, self.__fsm, leaf_list, i)
            if len(syn_sets) > 0:
                leaf_list[i].getLayerInfo().setLayerData(ViewLayerType.SEMANTICS, syn_sets[randrange(len(syn_sets))].getId())
        return True
