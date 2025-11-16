//
//  MinEntropyContainer.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 19.03.2025.
//

import Foundation

// A container optimized to find the superposition with minimal entropy.
// Uses a binary heap for O(log n) operations instead of O(n) dictionary lookups.
final class MinEntropyContainer<T: Topology> {
    typealias Superposition = T.Superposition
    
    // Heap-based priority queue for efficient min operations
    private var heap: [Superposition] = []
    private var pointToIndex: [T.Point: Int] = [:]
    private var count: Int = 0
    
    var isEmpty: Bool { count == 0 }
    
    init<C: Collection>(_ superpositions: C) where C.Element == Superposition {
        heap.reserveCapacity(superpositions.count)
        superpositions.forEach { append($0) }
    }
    
    func append(_ sup: Superposition) {
        heap.append(sup)
        pointToIndex[sup.point] = heap.count - 1
        count += 1
        siftUp(from: heap.count - 1)
    }
    
    func remove(_ sup: Superposition) {
        guard let index = pointToIndex[sup.point] else { return }
        
        // If removing the last element, just remove it
        if index == heap.count - 1 {
            heap.removeLast()
            pointToIndex.removeValue(forKey: sup.point)
            count -= 1
            return
        }
        
        // Replace with last element and sift down
        let lastElement = heap.removeLast()
        heap[index] = lastElement
        pointToIndex[lastElement.point] = index
        pointToIndex.removeValue(forKey: sup.point)
        count -= 1
        
        // Sift down from the replaced position
        siftDown(from: index)
    }
    
    func contains(_ sup: Superposition) -> Bool {
        return pointToIndex[sup.point] != nil
    }
    
    func getSuperposition() -> Superposition? {
        return heap.first
    }
    
    // MARK: - Heap Operations
    
    private func siftUp(from index: Int) {
        var currentIndex = index
        while currentIndex > 0 {
            let parentIndex = (currentIndex - 1) / 2
            if heap[currentIndex].entropy < heap[parentIndex].entropy {
                swapElements(at: currentIndex, and: parentIndex)
                currentIndex = parentIndex
            } else {
                break
            }
        }
    }
    
    private func siftDown(from index: Int) {
        var currentIndex = index
        while true {
            let leftChildIndex = 2 * currentIndex + 1
            let rightChildIndex = 2 * currentIndex + 2
            var smallestIndex = currentIndex
            
            if leftChildIndex < heap.count && heap[leftChildIndex].entropy < heap[smallestIndex].entropy {
                smallestIndex = leftChildIndex
            }
            
            if rightChildIndex < heap.count && heap[rightChildIndex].entropy < heap[smallestIndex].entropy {
                smallestIndex = rightChildIndex
            }
            
            if smallestIndex == currentIndex {
                break
            }
            
            swapElements(at: currentIndex, and: smallestIndex)
            currentIndex = smallestIndex
        }
    }
    
    private func swapElements(at index1: Int, and index2: Int) {
        heap.swapAt(index1, index2)
        pointToIndex[heap[index1].point] = index1
        pointToIndex[heap[index2].point] = index2
    }
    
    // MARK: - Performance Optimizations
    
    /// Updates the entropy of a superposition and rebalances the heap
    /// This is more efficient than remove + append for entropy changes
    func updateEntropy(for superposition: Superposition) {
        guard let index = pointToIndex[superposition.point] else { return }
        
        let oldEntropy = heap[index].entropy
        let newEntropy = superposition.entropy
        
        // Update the superposition in the heap
        heap[index] = superposition
        
        // Rebalance based on entropy change
        if newEntropy < oldEntropy {
            siftUp(from: index)
        } else if newEntropy > oldEntropy {
            siftDown(from: index)
        }
        // If entropy is the same, no rebalancing needed
    }
    
    /// Batch insert for better performance when adding multiple items
    func appendBatch<C: Collection>(_ superpositions: C) where C.Element == Superposition {
        let startIndex = heap.count
        superpositions.forEach { sup in
            heap.append(sup)
            pointToIndex[sup.point] = heap.count - 1
            count += 1
        }
        
        // Heapify from the bottom up (more efficient than individual siftUp calls)
        for i in stride(from: startIndex, to: heap.count, by: 1) {
            siftUp(from: i)
        }
    }
    
    /// Clears all elements efficiently
    func clear() {
        heap.removeAll(keepingCapacity: true)
        pointToIndex.removeAll(keepingCapacity: true)
        count = 0
    }
}
