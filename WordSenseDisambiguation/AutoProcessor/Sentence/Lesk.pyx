from random import randrange
import random

from AnnotatedSentence.AnnotatedSentence cimport AnnotatedSentence
from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from WordNet.SynSet cimport SynSet
from WordNet.WordNet cimport WordNet
from WordSenseDisambiguation.AutoProcessor.Sentence.SentenceAutoSemantic cimport SentenceAutoSemantic

cdef class Lesk(SentenceAutoSemantic):

    cdef WordNet __turkish_wordnet
    cdef FsmMorphologicalAnalyzer __fsm

    def __init__(self, turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer):
        """
        Constructor for the {@link Lesk} class. Gets the Turkish wordnet and Turkish fst based
        morphological analyzer from the user and sets the corresponding attributes.
        :param turkishWordNet: Turkish wordnet
        :param fsm: Turkish morphological analyzer
        """
        self.__fsm = fsm
        self.__turkish_wordnet = turkishWordNet

    cpdef int intersection(self, SynSet synSet, AnnotatedSentence sentence):
        """
        Calculates the number of words that occur (i) in the definition or example of the given synset and (ii) in the
        given sentence.
        :param synSet: Synset of which the definition or example will be checked
        :param sentence: Sentence to be annotated.
        :return: The number of words that occur (i) in the definition or example of the given synset and (ii) in the given
        sentence.
        """
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
        """
        The method annotates the word senses of the words in the sentence according to the simplified Lesk algorithm.
        Lesk is an algorithm that chooses the sense whose definition or example shares the most words with the target
        word’s neighborhood. The algorithm processes target words one by one. First, the algorithm constructs an array of
        all possible senses for the target word to annotate. Then for each possible sense, the number of words shared
        between the definition of sense synset and target sentence is calculated. Then the sense with the maximum
        intersection count is selected.
        :param sentence: Sentence to be annotated.
        :return: True, if at least one word is semantically annotated, false otherwise.
        """
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
