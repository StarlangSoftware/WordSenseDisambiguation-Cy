from random import randrange
import random

from AnnotatedSentence.ViewLayerType import ViewLayerType
from AnnotatedTree.ParseTreeDrawable cimport ParseTreeDrawable
from AnnotatedTree.Processor.Condition.IsTurkishLeafNode cimport IsTurkishLeafNode
from AnnotatedTree.Processor.NodeDrawableCollector cimport NodeDrawableCollector
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from WordNet.SynSet cimport SynSet
from WordNet.WordNet cimport WordNet
from WordSenseDisambiguation.AutoProcessor.ParseTree.TreeAutoSemantic cimport TreeAutoSemantic

cdef class Lesk(TreeAutoSemantic):

    cdef WordNet __turkish_wordnet
    cdef FsmMorphologicalAnalyzer __fsm

    def __init__(self, turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer):
        """
        Constructor for the {@link AutoProcessor.Sentence.Lesk} class. Gets the Turkish wordnet and Turkish fst based
        morphological analyzer from the user and sets the corresponding attributes.
        :param turkishWordNet: Turkish wordnet
        :param fsm: Turkish morphological analyzer
        """
        self.__fsm = fsm
        self.__turkish_wordnet = turkishWordNet

    cpdef int intersection(self, SynSet synSet, list leafList):
        """
        Calculates the number of words that occur (i) in the definition or example of the given synset and (ii) in the
        given parse tree.
        :param synSet: Synset of which the definition or example will be checked
        :param leafList: Leaf nodes of the parse tree.
        :return: The number of words that occur (i) in the definition or example of the given synset and (ii) in the given
        parse tree.
        """
        cdef list words1
        cdef list words2
        cdef int i, count
        cdef str word1, word2
        if synSet.getExample() is not None:
            words1 = (synSet.getLongDefinition() + " " + synSet.getExample()).split(" ")
        else:
            words1 = synSet.getLongDefinition().split(" ")
        words2 = []
        for i in range(len(leafList)):
            words2.append(leafList[i].getLayerData(ViewLayerType.TURKISH_WORD))
        count = 0
        for word1 in words1:
            for word2 in words2:
                if word1.lower() == word2.lower():
                    count = count + 1
        return count

    cpdef bint autoLabelSingleSemantics(self, ParseTreeDrawable parseTree):
        """
        The method annotates the word senses of the words in the parse tree according to the simplified Lesk algorithm.
        Lesk is an algorithm that chooses the sense whose definition or example shares the most words with the target
        word’s neighborhood. The algorithm processes target words one by one. First, the algorithm constructs an array of
        all possible senses for the target word to annotate. Then for each possible sense, the number of words shared
        between the definition of sense synset and target tree is calculated. Then the sense with the maximum
        intersection count is selected.
        :param parseTree: Parse tree to be annotated.
        :return: True, if at least one word is semantically annotated, false otherwise.
        """
        cdef int i, max_intersection, j, intersection_count
        cdef list leaf_list
        cdef bint done
        cdef NodeDrawableCollector node_drawable_collector
        cdef list syn_sets, max_syn_sets
        cdef SynSet synSet
        random.seed(1)
        node_drawable_collector = NodeDrawableCollector(parseTree.getRoot(), IsTurkishLeafNode())
        leaf_list = node_drawable_collector.collect()
        done = False
        for i in range(len(leaf_list)):
            syn_sets = self.getCandidateSynSets(self.__turkish_wordnet, self.__fsm, leaf_list, i)
            max_intersection = -1
            for j in range(len(syn_sets)):
                syn_set = syn_sets[j]
                intersection_count = self.intersection(syn_set, leaf_list)
                if intersection_count > max_intersection:
                    max_intersection = intersection_count
            max_syn_sets = []
            for j in range(len(syn_sets)):
                syn_set = syn_sets[j]
                if self.intersection(syn_set,leaf_list) == max_intersection:
                    max_syn_sets.append(syn_set)
            if len(max_syn_sets) > 0:
                leaf_list[i].getLayerInfo().setLayerData(ViewLayerType.SEMANTICS, max_syn_sets[randrange(len(max_syn_sets))].getId())
                done = True
        return done
