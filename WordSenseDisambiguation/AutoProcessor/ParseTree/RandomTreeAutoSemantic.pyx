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

    cdef WordNet __turkish_wordnet
    cdef FsmMorphologicalAnalyzer __fsm

    def __init__(self, turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer):
        """
        Constructor for the {@link RandomSentenceAutoSemantic} class. Gets the Turkish wordnet and Turkish fst based
        morphological analyzer from the user and sets the corresponding attributes.
        :param turkishWordNet: Turkish wordnet
        :param fsm: Turkish morphological analyzer
        """
        self.__fsm = fsm
        self.__turkish_wordnet = turkishWordNet

    cpdef bint autoLabelSingleSemantics(self, ParseTreeDrawable parseTree):
        """
        The method annotates the word senses of the words in the parse tree randomly. The algorithm processes target
        words one by one. First, the algorithm constructs an array of all possible senses for the target word to
        annotate. Then it chooses a sense randomly.
        :param parseTree: Parse tree to be annotated.
        :return: True.
        """
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
