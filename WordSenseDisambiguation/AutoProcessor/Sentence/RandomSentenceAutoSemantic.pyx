import random

from AnnotatedSentence.AnnotatedSentence cimport AnnotatedSentence
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from WordNet.WordNet cimport WordNet
from WordSenseDisambiguation.AutoProcessor.Sentence.SentenceAutoSemantic cimport SentenceAutoSemantic

cdef class RandomSentenceAutoSemantic(SentenceAutoSemantic):

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

    cpdef bint autoLabelSingleSemantics(self, AnnotatedSentence sentence):
        """
        The method annotates the word senses of the words in the sentence randomly. The algorithm processes target
        words one by one. First, the algorithm constructs an array of all possible senses for the target word to
        annotate. Then it chooses a sense randomly.
        :param sentence: Sentence to be annotated.
        :return: True.
        """
        cdef int i
        cdef list syn_sets
        random.seed(1)
        for i in range(sentence.wordCount()):
            syn_sets = self.getCandidateSynSets(self.__turkish_wordnet, self.__fsm, sentence, i)
            if len(syn_sets) > 0:
                sentence.getWord(i).setSemantic(syn_sets[random.randrange(len(syn_sets))].getId())
        return True
