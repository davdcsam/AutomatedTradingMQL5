//+------------------------------------------------------------------+
//|                                                        AtingMQL5 |
//|                                         Copyright 2024, davdcsam |
//|                            https://github.com/davdcsam/AtingMQL5 |
//+------------------------------------------------------------------+
#include <Arrays/ArrayInt.mqh>
#include <Arrays/ArrayObj.mqh>

//+------------------------------------------------------------------+
class TimeLapseTreeNode : public CObject
  {
public:
   int               identifier;
   datetime               startTime;
   datetime               endTime;
   TimeLapseTreeNode* left;
   TimeLapseTreeNode* right;

                     TimeLapseTreeNode(int id, datetime start, datetime end);

   virtual          ~TimeLapseTreeNode();
  };

//+------------------------------------------------------------------+
class TimeLapseTree
  {
private:
   TimeLapseTreeNode* root;

   TimeLapseTreeNode* InsertRecursive(TimeLapseTreeNode* node, int id, datetime start, datetime end);

   void              InorderRecursive(TimeLapseTreeNode* node);

   TimeLapseTreeNode* GetNode(TimeLapseTreeNode* node, int id);

   void              GetNodesInRange(CArrayObj &result, TimeLapseTreeNode* rootNode, datetime dt);

   void              CollectIdentifiers(TimeLapseTreeNode* node, CArrayInt &identifiers);

public:
                     TimeLapseTree();

                    ~TimeLapseTree();

   void              Insert(int id, datetime start, datetime end);
   void              Insert(TimeLapseTreeNode* newNode);

   bool              UpdateNode(int id, int newStart, int newEnd);
   bool              UpdateNode(TimeLapseTreeNode* newNode);

   void              TraverseInorder();

   TimeLapseTreeNode* GetNode(int id);

   void              GetNodesInRange(CArrayObj* &result, datetime dt);

   void              GetNodesByIdentifierCArr(CArrayObj &result, CArrayInt &identifiers);
   void              GetNodesByIdentifierArr(CArrayObj &result, int &identifiers[]);

   void              GetIdentifierInRange(CArrayInt &result, datetime dt);
   void              GetIdentifierInRange(int &result[], datetime dt);

   void              GetAllIdentifiers(CArrayInt &result);
   void              GetAllIdentifiers(int &result[]);
  };

//+------------------------------------------------------------------+
TimeLapseTreeNode::TimeLapseTreeNode(int id, datetime start, datetime end)
  {
   identifier = id;
   startTime = start;
   endTime = end;
   left = NULL;
   right = NULL;
  }

//+------------------------------------------------------------------+
TimeLapseTreeNode::~TimeLapseTreeNode()
  {
   if(left != NULL)
     {
      delete left;
      left = NULL;
     }
   if(right != NULL)
     {
      delete right;
      right = NULL;
     }
  }


//+------------------------------------------------------------------+
TimeLapseTree::TimeLapseTree()
  { root = NULL; }

//+------------------------------------------------------------------+
TimeLapseTree::~TimeLapseTree()
  {
   if(root != NULL)
      delete root;
  }

//+------------------------------------------------------------------+
TimeLapseTreeNode* TimeLapseTree::InsertRecursive(TimeLapseTreeNode* node, int id, datetime start, datetime end)
  {
   if(node == NULL)
      node = new TimeLapseTreeNode(id, start, end);
   else
     {
      if(id < node.identifier)
         node.left = InsertRecursive(node.left, id, start, end);
      else
         if(id > node.identifier)
            node.right = InsertRecursive(node.right, id, start, end);
     }
   return node;
  }

//+------------------------------------------------------------------+
void              TimeLapseTree::InorderRecursive(TimeLapseTreeNode* node)
  {
   if(node != NULL)
     {
      InorderRecursive(node.left);
      PrintFormat("Node id: %d start: %d end: %d", node.identifier, node.startTime, node.endTime);
      InorderRecursive(node.right);
     }
  }

//+------------------------------------------------------------------+
TimeLapseTreeNode* TimeLapseTree::GetNode(TimeLapseTreeNode* node, int id)
  {
   if(node == NULL)
      return NULL;

   if(id == node.identifier)
      return node;
   else
      if(id < node.identifier)
         return GetNode(node.left, id);
      else
         return GetNode(node.right, id);
  }

//+------------------------------------------------------------------+
void              TimeLapseTree::GetNodesInRange(CArrayObj &result, TimeLapseTreeNode* rootNode, datetime dt)
  {
   if(rootNode != NULL)
     {
      // Check the left subtree
      GetNodesInRange(result, rootNode.left, dt);

      // Check the current node
      if(dt >= rootNode.startTime && dt <= rootNode.endTime)
         result.Add(new TimeLapseTreeNode(rootNode.identifier, rootNode.startTime, rootNode.endTime));

      // Check the right subtree
      GetNodesInRange(result, rootNode.right, dt);
     }
  }

//+------------------------------------------------------------------+
void TimeLapseTree::CollectIdentifiers(TimeLapseTreeNode* node, CArrayInt &identifiers)
  {
   if(node != NULL)
     {
      CollectIdentifiers(node.left, identifiers);
      identifiers.Add(node.identifier);
      CollectIdentifiers(node.right, identifiers);
     }
  }

//+------------------------------------------------------------------+
void              TimeLapseTree::Insert(int id, datetime start, datetime end)
  { root = InsertRecursive(root, id, start, end); }

//+------------------------------------------------------------------+
void TimeLapseTree::Insert(TimeLapseTreeNode* newNode)
  {
   root = InsertRecursive(root, newNode.identifier, newNode.startTime, newNode.endTime);
  }

//+------------------------------------------------------------------+
bool              TimeLapseTree::UpdateNode(int id, int newStart, int newEnd)
  {
   TimeLapseTreeNode* node = GetNode(root, id);
   if(node != NULL)
     {
      node.startTime = newStart;
      node.endTime = newEnd;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool TimeLapseTree::UpdateNode(TimeLapseTreeNode *newNode)
  {
   TimeLapseTreeNode* node = GetNode(root, newNode.identifier);
   if(node != NULL)
     {
      node.startTime = newNode.startTime;
      node.endTime = newNode.endTime;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
void              TimeLapseTree::TraverseInorder()
  { InorderRecursive(root); }

//+------------------------------------------------------------------+
TimeLapseTreeNode* TimeLapseTree::GetNode(int id)
  { return GetNode(root, id); }

//+------------------------------------------------------------------+
void              TimeLapseTree::GetNodesInRange(CArrayObj* &result, datetime dt)
  {
   result = new CArrayObj();
   GetNodesInRange(result, root, dt);
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetNodesByIdentifierCArr(CArrayObj &result, CArrayInt &identifiers)
  {
   for(int i = 0; i < identifiers.Total(); i++)
     {
      TimeLapseTreeNode* node = GetNode(root, identifiers[i]);
      if(node != NULL)
        {
         result.Add(node);
        }
     }
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetNodesByIdentifierArr(CArrayObj &result, int &identifiers[])
  {
   for(int i = 0; i < ArraySize(identifiers); i++)
     {
      TimeLapseTreeNode* node = GetNode(root, identifiers[i]);
      if(node != NULL)
        {
         result.Add(node);
        }
     }
  }

//+------------------------------------------------------------------+
void              TimeLapseTree::GetIdentifierInRange(CArrayInt &result, datetime dt)
  {
   CArrayObj* nodesInRange;
   GetNodesInRange(nodesInRange, dt);

   for(int i = 0; i < nodesInRange.Total(); i++)
     {
      TimeLapseTreeNode* node = (TimeLapseTreeNode*)nodesInRange.At(i);
      if(node != NULL)
         result.Add(node.identifier);
      delete node;
     }

   delete nodesInRange;
  }

//+------------------------------------------------------------------+
void              TimeLapseTree::GetIdentifierInRange(int &result[], datetime dt)
  {
   CArrayObj* nodesInRange;
   GetNodesInRange(nodesInRange, dt);

   int total = nodesInRange.Total();

   ArrayResize(result, total);

   for(int i = 0; i < total; i++)
     {
      TimeLapseTreeNode* node = (TimeLapseTreeNode*)nodesInRange.At(i);
      if(node != NULL)
         result[i] = node.identifier;
      delete node;
     }

   delete nodesInRange;
  }

//+------------------------------------------------------------------+
void TimeLapseTree::GetAllIdentifiers(CArrayInt &result)
  {
   CollectIdentifiers(root, result);
  }


//+------------------------------------------------------------------+
void TimeLapseTree::GetAllIdentifiers(int &result[])
  {
   CArrayInt identifiers;
   CollectIdentifiers(root, identifiers);

   int total = identifiers.Total();
   ArrayResize(result, total);

   for(int i = 0; i < total; i++)
     {
      result[i] = identifiers[i];
     }
  }
//+------------------------------------------------------------------+
