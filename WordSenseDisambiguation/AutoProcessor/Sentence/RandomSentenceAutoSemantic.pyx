import random

from AnnotatedSentence.AnnotatedSentence cimport AnnotatedSentence
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from WordNet.WordNet cimport WordNet
from WordSenseDisambiguation.AutoProcessor.Sentence.SentenceAutoSemantic cimport SentenceAutoSemantic

cdef class RandomSentenceAutoSemantic(SentenceAutoSemantic):

    cpdef WordNet __turkish_wordnet
    cpdef FsmMorphologicalAnalyzer __fsm

    def __init__(self, turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer):
        self.__fsm = fsm
        self.__turkish_wordnet = turkishWordNet

    cpdef bint autoLabelSingleSemantics(self, AnnotatedSentence sentence):
        cdef int i
        cdef list syn_sets
        random.seed(1)
        for i in range(sentence.wordCount()):
            syn_sets = self.getCandidateSynSets(self.__turkish_wordnet, self.__fsm, sentence, i)
            if len(syn_sets) > 0:
                sentence.getWord(i).setSemantic(syn_sets[random.randrange(len(syn_sets))].getId())
        return True
