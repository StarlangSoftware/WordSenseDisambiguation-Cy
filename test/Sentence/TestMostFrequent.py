import unittest

from AnnotatedSentence.AnnotatedCorpus import AnnotatedCorpus
from MorphologicalAnalysis.FsmMorphologicalAnalyzer import FsmMorphologicalAnalyzer
from WordNet.WordNet import WordNet

from WordSenseDisambiguation.AutoProcessor.Sentence.MostFrequentSentenceAutoSemantic import MostFrequentSentenceAutoSemantic


class MostFrequent(unittest.TestCase):

    fsm: FsmMorphologicalAnalyzer
    wordNet: WordNet

    def setUp(self) -> None:
        self.fsm = FsmMorphologicalAnalyzer()
        self.wordNet = WordNet()

    def test_Accuracy(self):
        correct = 0
        total = 0
        mostFrequent = MostFrequentSentenceAutoSemantic(self.wordNet, self.fsm)
        corpus1 = AnnotatedCorpus("../../new-sentences")
        corpus2 = AnnotatedCorpus("../../old-sentences")
        for i in range(corpus1.sentenceCount()):
            sentence1 = corpus1.getSentence(i)
            mostFrequent.autoSemantic(sentence1)
            sentence2 = corpus2.getSentence(i)
            for j in range(sentence1.wordCount()):
                total = total + 1
                word1 = sentence1.getWord(j)
                word2 = sentence2.getWord(j)
                if word1.getSemantic() is not None and word1.getSemantic() == word2.getSemantic():
                    correct = correct + 1
        self.assertEqual(549, total)
        self.assertEqual(278, correct)


if __name__ == '__main__':
    unittest.main()
