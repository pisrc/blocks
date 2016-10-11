import Foundation
import CoreData


// MARK: - NSManagedObjectContext 확장

extension NSManagedObjectContext {
    
    public func insert<E:NSManagedObject>(makeEntity: (E) -> Void) -> E {
        let entityName = String(describing: E.self)
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? E else {
            fatalError("Type casting error. (\(E.self))")
        }
        makeEntity(entity)
        return entity
    }
    
    public func selectAll(forEntityName entityName: String, predicate: NSPredicate?) -> [AnyObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            return try fetch(request)
        } catch {
            fatalError("\(error)")
        }
    }
    
    public func select(forEntityName entityName: String) -> AnyObject? {
        let records = selectAll(forEntityName: entityName, predicate: nil)
        return records.first
    }
    
    public func select(forEntityName entityName: String, predicate: NSPredicate) -> AnyObject? {
        let records = selectAll(forEntityName: entityName, predicate: predicate)
        return records.first
    }
    
    public func doSave(_ successHandler: (() -> ())? = nil) {
        do {
            try save()
            successHandler?()
        } catch {
            print("\(error)")
        }
    }
}
