import Foundation
import TSCBasic
import TSCUtility
import TuistAutomation
import TuistCore
import TuistGenerator
import TuistGraph

protocol WorkspaceMapperFactorying {
    /// Returns the default workspace mapper.
    /// - Returns: A workspace mapping instance.
    func `default`() -> [WorkspaceMapping]

    /// Returns a mapper to generate cacheable prorjects.
    /// - Parameter config: The project configuration.
    /// - Parameter includedTargets: The list of targets to cache.
    /// - Returns: A workspace mapping instance.
    func cache(includedTargets: Set<String>) -> [WorkspaceMapping]

    /// Returns a mapper for automation commands like build and test.
    /// - Parameter config: The project configuration.
    /// - Parameter workspaceDirectory: The directory where the workspace will be generated.
    /// - Returns: A workspace mapping instance.
    func automation(workspaceDirectory: AbsolutePath) -> [WorkspaceMapping]
}

final class WorkspaceMapperFactory: WorkspaceMapperFactorying {
    private let projectMapper: ProjectMapping

    init(projectMapper: ProjectMapping) {
        self.projectMapper = projectMapper
    }

    func cache(includedTargets: Set<String>) -> [WorkspaceMapping] {
        var mappers = self.default(forceWorkspaceSchemes: false)
        mappers += [GenerateCacheableSchemesWorkspaceMapper(includedTargets: includedTargets)]
        return mappers
    }

    func automation(workspaceDirectory: AbsolutePath) -> [WorkspaceMapping] {
        var mappers: [WorkspaceMapping] = []
        mappers.append(AutomationPathWorkspaceMapper(workspaceDirectory: workspaceDirectory))
        mappers += self.default(forceWorkspaceSchemes: true)

        return mappers
    }

    func `default`() -> [WorkspaceMapping] {
        self.default(forceWorkspaceSchemes: false)
    }

    private func `default`(forceWorkspaceSchemes: Bool) -> [WorkspaceMapping] {
        var mappers: [WorkspaceMapping] = []

        mappers.append(
            ProjectWorkspaceMapper(mapper: projectMapper)
        )

        mappers.append(
            TuistWorkspaceIdentifierMapper()
        )

        mappers.append(
            TuistWorkspaceRenderMarkdownReadmeMapper()
        )

        mappers.append(
            IDETemplateMacrosMapper()
        )

        mappers.append(
            AutogeneratedWorkspaceSchemeWorkspaceMapper(forceWorkspaceSchemes: forceWorkspaceSchemes)
        )

        mappers.append(
            ModuleMapMapper()
        )

        mappers.append(
            LastUpgradeVersionWorkspaceMapper()
        )

        return mappers
    }
}
