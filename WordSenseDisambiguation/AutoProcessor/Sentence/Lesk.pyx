from random import randrange
import random

from AnnotatedSentence.AnnotatedSentence cimport AnnotatedSentence
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from WordNet.SynSet cimport SynSet
from WordNet.WordNet cimport WordNet
from WordSenseDisambiguation.AutoProcessor.Sentence.SentenceAutoSemantic cimport SentenceAutoSemantic

cdef class Lesk(SentenceAutoSemantic):

    cpdef WordNet __turkish_wordnet
    cpdef FsmMorphologicalAnalyzer __fsm

    def __init__(self, turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer):
        self.__fsm = fsm
        self.__turkish_wordnet = turkishWordNet

    cpdef int intersection(self, SynSet synSet, AnnotatedSentence sentence):
        cdef list words1, words2
        cdef int count
        cdef str word1, word2
        if synSet.getExample() is not None:
            words1 = (synSet.getLongDefinition() + " " + synSet.getExample()).split(" ")
        else:
            words1 = synSet.getLongDefinition().split(" ")
        words2 = sentence.toString().split(" ")
        count = 0
        for word1 in words1:
            for word2 in words2:
                if word1.lower() == word2.lower():
                    count = count + 1
        return count

    cpdef bint autoLabelSingleSemantics(self, sentence: AnnotatedSentence):
        cdef bint done
        cdef int i, j, max_intersection, intersection_count
        cdef list syn_sets, max_syn_sets
        cdef SynSet syn_set
        random.seed(1)
        done = False
        for i in range(sentence.wordCount()):
            syn_sets = self.getCandidateSynSets(self.__turkish_wordnet, self.__fsm, sentence, i)
            max_intersection = -1
            for j in range(len(syn_sets)):
                syn_set = syn_sets[j]
                intersection_count = self.intersection(syn_set, sentence)
                if intersection_count > max_intersection:
                    max_intersection = intersection_count
            max_syn_sets = []
            for j in range(len(syn_sets)):
                syn_set = syn_sets[j]
                if self.intersection(syn_set, sentence) == max_intersection:
                    max_syn_sets.append(syn_set)
            if len(max_syn_sets) > 0:
                done = True
                sentence.getWord(i).setSemantic(max_syn_sets[randrange(len(max_syn_sets))].getId())
        return done
